// Writes the outside sources the other tools read into docs/: Windower's resource files into docs/windower, from the
// branch head of Windower/Resources, and wsdist's gear data, gear.py, into docs/wsdist, from IzaKastra/wsdist_beta at
// the commit docs/ffxi-mechanics.md cites file and line numbers from. Run it after a game update; the update-ext-data
// skill runs it with the rest of the outside data.
//
//   dotnet run .claude/gear.cs -- fetch-sources
//
// It writes nothing unless it got every file.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Net.Http;
using GearTools;

new Arguments(args, [], []);
var resources = Sources.ResourceFiles.Select(file => (Path: Tool.InRepo("docs", "windower", file), Bytes: Download(file))).ToList();
var checkout = Sources.Checkout("wsdist_beta");
byte[]? gear;
try
{
	var fetched = Path.Combine(checkout, "gear.py");
	gear = File.Exists(fetched) ? File.ReadAllBytes(fetched) : null;
}
finally
{
	Sources.RemoveCheckout(checkout);
}
var commit = Sources.Pin("wsdist_beta").Commit[..7];
if (gear is null)
	Tool.Fail($"wsdist_beta has no gear.py at {commit}.");

foreach (var resource in resources)
{
	Write(resource.Path, resource.Bytes);
	Console.WriteLine($"{Tool.RepoRelative(resource.Path)}: downloaded ({resource.Bytes.Length / 1024} KB)");
}
var gearPath = Tool.InRepo("docs", "wsdist", "gear.py");
Write(gearPath, gear);
Console.WriteLine($"{Tool.RepoRelative(gearPath)}: from wsdist_beta at {commit} ({gear.Length / 1024} KB)");

// A download that fails stops the tool, before anything is written.
static byte[] Download(string file)
{
	try
	{
		using var http = new HttpClient();
		return http.GetByteArrayAsync(Sources.ResourcesUrl + file).GetAwaiter().GetResult();
	}
	catch (Exception problem) when (problem is HttpRequestException or TaskCanceledException)
	{
		Tool.Fail($"Windower's {file}: couldn't download it. {problem.Message}");
		throw;
	}
}

// Windows won't replace a file another tool has open, and says so.
static void Write(string path, byte[] bytes)
{
	try
	{
		Directory.CreateDirectory(Path.GetDirectoryName(path)!);
		File.WriteAllBytes(path, bytes);
	}
	catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
	{
		Tool.Fail($"{Tool.RepoRelative(path)}: couldn't write it. {problem.Message}");
	}
}
