using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Net;
using System.Net.Http;
using System.Text.Json;

namespace GearTools;

// Reads bg-wiki pages as wikitext through its MediaWiki API, up to 40 titles to a request. bg-wiki rate limits
// page-by-page reads quickly, and one batched request counts once.
static class Wiki
{
	// Every title asked for that exists, keyed as it was asked for. A missing page has no entry.
	public static async Task<Dictionary<string, WikiPage>> Fetch(IReadOnlyList<string> titles)
	{
		using var http = new HttpClient();
		// bg-wiki turns away the default .NET agent string.
		http.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36");
		var found = new Dictionary<string, WikiPage>();
		var first = true;
		foreach (var batch in titles.Distinct().Chunk(40))
		{
			if (first is false)
				await Task.Delay(TimeSpan.FromSeconds(2));
			first = false;
			var url = "https://www.bg-wiki.com/api.php?action=query&prop=revisions&rvprop=content&rvslots=main&redirects=1&format=json&formatversion=2&titles="
				+ Uri.EscapeDataString(string.Join("|", batch));
			using var reply = JsonDocument.Parse(await Get(http, url));
			var query = reply.RootElement.GetProperty("query");

			// The wiki answers under the title it settled on: underscores become spaces, and a redirect is followed.
			var renamed = new Dictionary<string, string>();
			string[] renames = ["normalized", "redirects"];
			foreach (var kind in renames)
			{
				if (query.TryGetProperty(kind, out var entries) is false)
					continue;
				foreach (var entry in entries.EnumerateArray())
					renamed[entry.GetProperty("from").GetString()!] = entry.GetProperty("to").GetString()!;
			}
			var texts = new Dictionary<string, string>();
			foreach (var page in query.GetProperty("pages").EnumerateArray())
			{
				if (page.TryGetProperty("missing", out _) is false && page.TryGetProperty("revisions", out var revisions))
					texts[page.GetProperty("title").GetString()!] = revisions[0].GetProperty("slots").GetProperty("main").GetProperty("content").GetString()!;
			}
			foreach (var asked in batch)
			{
				var title = asked;
				for (var hop = 0; hop < 3 && renamed.TryGetValue(title, out var next); hop++)
					title = next;
				if (texts.TryGetValue(title, out var text))
					found[asked] = new WikiPage(title, text);
			}
		}
		return found;
	}

	// A 429 means wait: bg-wiki lifts its limit after about half a minute.
	static async Task<string> Get(HttpClient http, string url)
	{
		for (var attempt = 1; ; attempt++)
		{
			using var response = await http.GetAsync(url);
			if (response.StatusCode == HttpStatusCode.TooManyRequests && attempt < 6)
			{
				Console.Error.WriteLine("bg-wiki is rate limiting; waiting 30 seconds");
				await Task.Delay(TimeSpan.FromSeconds(30));
				continue;
			}
			if (response.IsSuccessStatusCode is false)
				Tool.Fail($"bg-wiki answered {(int)response.StatusCode} for {url}");
			return await response.Content.ReadAsStringAsync();
		}
	}
}

// One wiki page: the title the wiki settled on, after any redirect, and its wikitext.
sealed class WikiPage
{
	public string Title { get; }

	public string Text { get; }

	public WikiPage(string title, string text)
	{
		Title = title;
		Text = text;
	}
}
