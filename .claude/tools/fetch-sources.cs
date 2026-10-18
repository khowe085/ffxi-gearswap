// Fills .claude/cache with the outside sources the other tools and the docs read: Windower's resource files and
// the two IzaKastra repos, each at the commit docs/ffxi-mechanics.md cites file and line numbers from. The other
// tools fetch what they read when the cache lacks it, so this is for fetching the resources again after a game update
// (--refresh), or everything at once.
//
//   dotnet run .claude/gear.cs -- fetch-sources [--refresh]
//
// Without --refresh it only fetches what is missing. The cache is git-ignored; nothing here is checked in.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using GearTools;

var cli = new Arguments(args, [], ["--refresh"]);
foreach (var file in Sources.ResourceFiles)
	Console.WriteLine(File.Exists(Tool.InCache("res", file)) && cli.Flag("--refresh") is false ? Sources.Describe(file) : Sources.Download(file));
foreach (var name in Sources.RepoNames)
	Console.WriteLine($"{name}: {Sources.FetchRepo(name)}");
