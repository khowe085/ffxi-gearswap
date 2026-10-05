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
	// The tests (tests/run-tests.cs) set GEAR_TOOLS_WIKI to the address of a stand-in for the API on their own machine.
	static string Query => (Environment.GetEnvironmentVariable("GEAR_TOOLS_WIKI") ?? "https://www.bg-wiki.com/api.php")
		+ "?action=query&prop=revisions&rvprop=content&rvslots=main&redirects=1&format=json&formatversion=2";

	static JsonSerializerOptions replyOptions;

	static Wiki()
	{
		// The API writes its names in lower case.
		replyOptions = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
	}

	// Every title asked for that exists, keyed as it was asked for. A missing page has no entry. The tool stops when
	// the wiki can't be reached or its reply can't be used.
	public static async Task<Dictionary<string, WikiPage>> Fetch(IReadOnlyList<string> titles)
	{
		using var http = new HttpClient();
		// MediaWiki asks a tool to say what it is.
		http.DefaultRequestHeaders.UserAgent.ParseAdd("ffxi-gearswap-tools/1.0 (reads gear pages for a player's GearSwap sets)");
		var first = true;
		try
		{
			return await Fetch(titles, async url =>
			{
				if (first is false)
					await Task.Delay(TimeSpan.FromSeconds(2));
				first = false;
				return await Get(http, url);
			});
		}
		catch (InvalidOperationException problem)
		{
			Tool.Fail(problem.Message);
			throw;
		}
		catch (Exception problem) when (problem is HttpRequestException or TaskCanceledException)
		{
			Tool.Fail($"Couldn't reach bg-wiki: {problem.Message}");
			throw;
		}
	}

	// The same, over any way of getting the body at a URL, so the tests can stand in for the wiki. It throws when a
	// reply can't be used.
	public static async Task<Dictionary<string, WikiPage>> Fetch(IReadOnlyList<string> titles, Func<string, Task<string>> get)
	{
		var found = new Dictionary<string, WikiPage>();
		foreach (var batch in titles.Distinct().Chunk(40))
		{
			var url = Query + "&titles=" + Uri.EscapeDataString(string.Join("|", batch));
			var texts = new Dictionary<string, string>();
			var renamed = new Dictionary<string, string>();
			// The API cuts a long reply short and says how to ask for the rest. Each part brings at least one more
			// page, so a batch that takes more parts than it has titles isn't going to end.
			var rest = "";
			for (var part = 1; ; part++)
			{
				var reply = Read(await get(url + rest));
				foreach (var text in reply.Texts)
					texts[text.Key] = text.Value;
				foreach (var rename in reply.Renamed)
					renamed[rename.Key] = rename.Value;
				if (reply.Continue.Count == 0)
					break;
				if (part > batch.Length)
					throw new InvalidOperationException($"bg-wiki kept answering in parts: {part} so far for {batch.Length} pages.");
				rest = string.Concat(reply.Continue.OrderBy(pair => pair.Key, StringComparer.Ordinal).Select(pair => $"&{pair.Key}={Uri.EscapeDataString(pair.Value)}"));
			}
			foreach (var asked in batch)
			{
				var title = Settled(asked, renamed);
				if (texts.TryGetValue(title, out var text))
					found[asked] = new WikiPage(title, text);
			}
		}
		return found;
	}

	// One reply of the API, taken apart. It throws when the reply is an error, or isn't the API's at all.
	public static WikiReply Read(string json)
	{
		ReplyJson? reply;
		try
		{
			reply = JsonSerializer.Deserialize<ReplyJson>(json, replyOptions);
		}
		catch (JsonException problem)
		{
			throw new InvalidOperationException($"bg-wiki's reply isn't JSON: {problem.Message}");
		}
		if (reply?.Error is not null)
			throw new InvalidOperationException($"bg-wiki's API answered with an error, {reply.Error.Code}: {reply.Error.Info}");
		if (reply?.Query is null)
			throw new InvalidOperationException("bg-wiki's API answered without a query result.");
		var renamed = new Dictionary<string, string>();
		foreach (var rename in reply.Query.Normalized.Concat(reply.Query.Redirects))
			renamed[rename.From] = rename.To;
		// A page that doesn't exist comes back with a title and no revision.
		var texts = new Dictionary<string, string>();
		foreach (var page in reply.Query.Pages)
		{
			if (page.Revisions.FirstOrDefault()?.Slots?.Main?.Content is { } content)
				texts[page.Title] = content;
		}
		return new WikiReply(texts, renamed, reply.Continue.ToDictionary(pair => pair.Key, pair => pair.Value.ToString()));
	}

	// The title the wiki settled on for one that was asked for: underscores become spaces, and a redirect is followed.
	public static string Settled(string asked, IReadOnlyDictionary<string, string> renamed)
	{
		var title = asked;
		// One step for the spelling and one for the redirect. The limit is there for renames that lead in a circle.
		for (var hop = 0; hop < 3 && renamed.TryGetValue(title, out var next); hop++)
			title = next;
		return title;
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

	sealed class ReplyJson
	{
		public ErrorJson? Error { get; set; }

		public QueryJson? Query { get; set; }

		public Dictionary<string, JsonElement> Continue { get; set; }

		public ReplyJson()
		{
			Continue = [];
		}
	}

	sealed class ErrorJson
	{
		public string Code { get; set; }

		public string Info { get; set; }

		public ErrorJson()
		{
			Code = "";
			Info = "";
		}
	}

	sealed class QueryJson
	{
		public List<RenameJson> Normalized { get; set; }

		public List<RenameJson> Redirects { get; set; }

		public List<PageJson> Pages { get; set; }

		public QueryJson()
		{
			Normalized = [];
			Redirects = [];
			Pages = [];
		}
	}

	sealed class RenameJson
	{
		public string From { get; set; }

		public string To { get; set; }

		public RenameJson()
		{
			From = "";
			To = "";
		}
	}

	sealed class PageJson
	{
		public string Title { get; set; }

		public List<RevisionJson> Revisions { get; set; }

		public PageJson()
		{
			Title = "";
			Revisions = [];
		}
	}

	sealed class RevisionJson
	{
		public SlotsJson? Slots { get; set; }
	}

	sealed class SlotsJson
	{
		public SlotJson? Main { get; set; }
	}

	sealed class SlotJson
	{
		public string? Content { get; set; }
	}
}

sealed class WikiReply
{
	// The wikitext of each page the reply carries, by the title the wiki settled on.
	public IReadOnlyDictionary<string, string> Texts { get; }

	// The titles the wiki renamed on the way: the one asked for, and the one it answered under.
	public IReadOnlyDictionary<string, string> Renamed { get; }

	// What to add to the request to get the rest, when the wiki cut the reply short. Empty when the reply is whole.
	public IReadOnlyDictionary<string, string> Continue { get; }

	public WikiReply(IReadOnlyDictionary<string, string> texts, IReadOnlyDictionary<string, string> renamed, IReadOnlyDictionary<string, string> @continue)
	{
		Texts = texts;
		Renamed = renamed;
		Continue = @continue;
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
