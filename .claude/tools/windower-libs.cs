// Writes the Windower libraries GearSwap's tests run on into docs/windower/libs, from Windower/Lua at the commit
// lib/Sources.cs pins: each library Sources.WindowerLibraries names, by its path under addons/libs. A library no
// longer named is dropped. It writes nothing unless the commit has every library.
//
//   dotnet run .claude/gear.cs -- windower-libs
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using GearTools;

new Arguments(args, [], []);
var commit = Sources.Pin("windower_lua").Commit[..7];
var checkout = Sources.Checkout("windower_lua");
string? missing;
List<(string Library, byte[] Bytes)> libraries;
try
{
	string InCheckout(string library) => Path.Combine([checkout, "addons", "libs", .. library.Split('/')]);
	missing = Sources.WindowerLibraries.FirstOrDefault(library => File.Exists(InCheckout(library)) is false);
	libraries = missing is null ? Sources.WindowerLibraries.Select(library => (library, File.ReadAllBytes(InCheckout(library)))).ToList() : [];
}
finally
{
	Sources.RemoveCheckout(checkout);
}
if (missing is not null)
	Tool.Fail($"Windower/Lua has no addons/libs/{missing} at {commit}.");
var target = Tool.InRepo("docs", "windower", "libs");
string InTarget(string library) => Path.GetFullPath(Path.Combine([target, .. library.Split('/')]));
var written = libraries.Select(library => InTarget(library.Library)).ToHashSet(StringComparer.Ordinal);
try
{
	foreach (var library in libraries)
	{
		var path = InTarget(library.Library);
		Directory.CreateDirectory(Path.GetDirectoryName(path)!);
		File.WriteAllBytes(path, library.Bytes);
	}
	// Only once every library is written, so a write that fails leaves the tests none short.
	foreach (var gone in Directory.GetFiles(target, "*", SearchOption.AllDirectories).Where(file => written.Contains(Path.GetFullPath(file)) is false))
		File.Delete(gone);
	foreach (var folder in Directory.GetDirectories(target, "*", SearchOption.AllDirectories).OrderByDescending(folder => folder.Length))
	{
		if (Directory.EnumerateFileSystemEntries(folder).Any() is false)
			Directory.Delete(folder);
	}
}
catch (Exception problem) when (problem is IOException or UnauthorizedAccessException)
{
	Tool.Fail($"{Tool.RepoRelative(target)}: couldn't write it. {problem.Message}");
}
Console.WriteLine($"{libraries.Count} Windower libraries from Windower/Lua at {commit} in {Tool.RepoRelative(target)}");
