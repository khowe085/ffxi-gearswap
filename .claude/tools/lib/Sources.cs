using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.ComponentModel;
using System.IO;

namespace GearTools;

// Where the outside data checked in under docs/ comes from: Windower's resource files, and the pinned repos
// IzaKastra/wsdist_beta, IzaKastra/bg_job_guides and Windower/Lua. fetch-sources.cs, simulated-sets.cs and
// windower-libs.cs write it; the other tools read it from docs/ and fetch nothing.
static class Sources
{
	public static IReadOnlyList<string> ResourceFiles { get; }

	// The Windower libraries GearSwap, Sel and the libraries they load require, by their paths under Windower/Lua's
	// addons/libs. GearSwap's tests run on these, from docs/windower/libs.
	public static IReadOnlyList<string> WindowerLibraries { get; }

	// Windower's resources follow the live game, so they are taken from the branch head, not pinned. The tests point
	// GEAR_TOOLS_RESOURCES at a stand-in on their own machine.
	public static string ResourcesUrl => Environment.GetEnvironmentVariable("GEAR_TOOLS_RESOURCES") ?? "https://raw.githubusercontent.com/Windower/Resources/master/resources_data/";

	static Dictionary<string, PinnedRepo> pins;

	static Sources()
	{
		ResourceFiles = ["items.lua", "item_descriptions.lua", "spells.lua"];
		WindowerLibraries = ["actions.lua", "chat.lua", "chat/chars.lua", "chat/colors.lua", "chat/controls.lua", "config.lua",
			"extdata.lua", "files.lua", "functions.lua", "json.lua", "lists.lua", "logger.lua", "maths.lua", "packets.lua",
			"packets/data.lua", "packets/fields.lua", "queues.lua", "resources.lua", "sets.lua", "slips.lua", "strings.lua",
			"tables.lua", "texts.lua", "xml.lua"];
		// docs/ffxi-mechanics.md quotes the first two by file and line, so a different commit would make its references
		// wrong. Windower/Lua is pinned to a commit of the live branch, the one Windower installs, so the tests run on
		// the same libraries until the pin moves.
		pins = new()
		{
			["wsdist_beta"] = new PinnedRepo("https://github.com/IzaKastra/wsdist_beta", "d12ac5923ccace977ad55d172c8698b5886b9e4f"),
			["bg_job_guides"] = new PinnedRepo("https://github.com/IzaKastra/bg_job_guides", "f264ae4f3bceb4d6e98bb7df5c4c22b21315c407"),
			["windower_lua"] = new PinnedRepo("https://github.com/Windower/Lua", "5a35aeffa01aa47ea2a7898a7015fccb586728a0"),
		};
	}

	// A pinned repo, or the one the tests point it at: GEAR_TOOLS_REPO_<NAME> is "<url> <commit>". The commit has no
	// space in it, and the url may.
	public static PinnedRepo Pin(string name)
	{
		var standIn = Environment.GetEnvironmentVariable("GEAR_TOOLS_REPO_" + name.ToUpperInvariant());
		return standIn?.LastIndexOf(' ') is > 0 and var space ? new PinnedRepo(standIn[..space], standIn[(space + 1)..]) : pins[name];
	}

	// Fetches a pinned repo at its commit into a new temp folder, for the caller to read and then remove with
	// RemoveCheckout. A git failure removes the folder and stops the tool.
	public static string Checkout(string name)
	{
		var pin = Pin(name);
		var folder = Path.Combine(Path.GetTempPath(), $"{name}-{Guid.NewGuid().ToString("N")[..8]}");
		try
		{
			GitSource.Fetch(folder, pin.Url, pin.Commit);
			return folder;
		}
		catch (InvalidOperationException problem)
		{
			RemoveCheckout(folder);
			Tool.Fail($"{name}: {problem.Message}");
			throw;
		}
		catch (Win32Exception problem)
		{
			RemoveCheckout(folder);
			Tool.Fail($"{name}: couldn't run git, which fetching it takes. {problem.Message}");
			throw;
		}
	}

	// Git marks its object files read-only, which stops a plain delete on Windows.
	public static void RemoveCheckout(string folder)
	{
		if (Directory.Exists(folder) is false)
			return;
		foreach (var file in Directory.GetFiles(folder, "*", SearchOption.AllDirectories))
			File.SetAttributes(file, FileAttributes.Normal);
		Directory.Delete(folder, true);
	}
}

// A git repository at the one commit the docs cite.
sealed class PinnedRepo
{
	public string Url { get; }

	public string Commit { get; }

	public PinnedRepo(string url, string commit)
	{
		Url = url;
		Commit = commit;
	}
}
