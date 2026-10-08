using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using System.IO;

namespace GearTools;

// Keeps a folder of the cache at one commit of a git repository, for the sources the docs cite by file and line.
static class GitSource
{
	// Checks the commit out into the folder unless it is there already, and says which happened. It throws when
	// git fails. A folder a failed fetch left half made is picked up where it stopped.
	public static string Fetch(string dir, string url, string commit)
	{
		if (Directory.Exists(Path.Combine(dir, ".git")) is false)
		{
			Directory.CreateDirectory(dir);
			Git(dir, "init", "--quiet");
		}
		// No commit yet means a fetch never finished here.
		var head = TryGit(dir, "rev-parse", "--verify", "--quiet", "HEAD")?.Trim();
		if (head == commit)
			return $"present at {commit[..7]}";
		if (TryGit(dir, "remote", "get-url", "origin") is null)
		{
			Git(dir, "remote", "add", "origin", url);
		}
		else
		{
			Git(dir, "remote", "set-url", "origin", url);
		}
		// wsdist_beta carries a 76 MB build of its GUI. Leaving executables out of the checkout, with the blob
		// filter below, means it is never downloaded.
		Git(dir, "sparse-checkout", "set", "--no-cone", "/*", "!*.exe");
		// One commit, no history, and only the files the checkout needs: the tools only read them.
		Git(dir, "fetch", "--quiet", "--depth", "1", "--filter=blob:none", "origin", commit);
		Git(dir, "checkout", "--quiet", "--detach", "FETCH_HEAD");
		return head is null ? $"fetched {commit[..7]} from {url}" : $"moved from {head[..7]} to {commit[..7]}";
	}

	static string Git(string dir, params string[] arguments) =>
		TryGit(dir, out var error, arguments) ?? throw new InvalidOperationException($"git {string.Join(" ", arguments)} failed in {dir}: {error}");

	static string? TryGit(string dir, params string[] arguments) => TryGit(dir, out _, arguments);

	// What git printed, or null when it failed, with what it said in error.
	static string? TryGit(string dir, out string error, params string[] arguments)
	{
		var start = new ProcessStartInfo("git") { WorkingDirectory = dir, RedirectStandardOutput = true, RedirectStandardError = true };
		foreach (var argument in arguments)
			start.ArgumentList.Add(argument);
		using var process = Process.Start(start)!;
		// Read both streams at once, so a full error pipe can't stall git while this waits on its output.
		var errorText = process.StandardError.ReadToEndAsync();
		var output = process.StandardOutput.ReadToEnd();
		process.WaitForExit();
		error = errorText.Result.Trim();
		return process.ExitCode == 0 ? output : null;
	}
}
