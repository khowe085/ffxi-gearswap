// Fills .claude/cache with the outside sources the other tools and the docs read: Windower's resource files and
// the two IzaKastra repos, each at the commit docs/ffxi-mechanics.md cites file and line numbers from.
//
//   dotnet run --no-cache .claude/tools/fetch-sources.cs [-- --refresh]
//
// Without --refresh it only fetches what is missing. The cache is git-ignored; nothing here is checked in.
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Net.Http;
using GearTools;

Tool.Init();
var cli = new Arguments(args, [], ["--refresh"]);
var refresh = cli.Flag("--refresh");

// Windower's resources follow the live game, so they are taken from the branch head, not pinned.
string[] resourceFiles = ["items.lua", "item_descriptions.lua", "spells.lua"];
var resourceDir = Tool.InCache("res");
Directory.CreateDirectory(resourceDir);
using var http = new HttpClient();
foreach (var file in resourceFiles)
{
	var path = Path.Combine(resourceDir, file);
	if (File.Exists(path) && refresh is false)
	{
		Console.WriteLine($"res/{file}: present ({new FileInfo(path).Length / 1024} KB, from {File.GetLastWriteTime(path):yyyy-MM-dd})");
		continue;
	}
	byte[] bytes;
	try
	{
		bytes = await http.GetByteArrayAsync("https://raw.githubusercontent.com/Windower/Resources/master/resources_data/" + file);
	}
	catch (Exception problem) when (problem is HttpRequestException or TaskCanceledException)
	{
		Tool.Fail($"res/{file}: couldn't download it. {problem.Message}");
		throw;
	}
	await File.WriteAllBytesAsync(path, bytes);
	Console.WriteLine($"res/{file}: downloaded ({bytes.Length / 1024} KB)");
}

// docs/ffxi-mechanics.md quotes these two by file and line, so a different commit would make its references wrong.
FetchRepo("wsdist_beta", "https://github.com/IzaKastra/wsdist_beta", "d12ac5923ccace977ad55d172c8698b5886b9e4f");
FetchRepo("bg_job_guides", "https://github.com/IzaKastra/bg_job_guides", "f264ae4f3bceb4d6e98bb7df5c4c22b21315c407");

void FetchRepo(string name, string url, string commit)
{
	try
	{
		Console.WriteLine($"{name}: {GitSource.Fetch(Tool.InCache(name), url, commit)}");
	}
	catch (InvalidOperationException problem)
	{
		Tool.Fail($"{name}: {problem.Message}");
	}
}
