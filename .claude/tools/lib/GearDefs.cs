using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// One Lua file read for its gear: the entries it defines with hp_gear, mp_gear or rank_gear, and every place a
// set or a hook puts a gear.<key> in a slot. It reads the text; it doesn't run Lua.
sealed class LuaGearFile
{
	public string Path { get; }

	public string FileName => System.IO.Path.GetFileName(Path);

	public IReadOnlyList<GearDef> Defs { get; }

	public IReadOnlyList<GearUse> Uses { get; }

	// Every key the file mentions outside its own definitions.
	public IReadOnlySet<string> ReferencedKeys { get; }

	// Lines that mention gear.<key> outside a definition and outside a "slot = gear.<key>" pair.
	public IReadOnlyList<string> LooseReferences { get; }

	// "slot = <something other than gear.<key> or empty>" inside a set's table, such as an item named by a string.
	public IReadOnlyList<string> DirectSlotValues { get; }

	static Regex definition;
	static Regex setAssignment;
	static Regex slotPair;
	static Regex anyReference;
	static Regex function;
	static Regex stringLiteral;
	static Regex directValue;

	static LuaGearFile()
	{
		definition = new Regex(@"\bgear\.(\w+)\s*=\s*(hp_gear|mp_gear|rank_gear)\(");
		setAssignment = new Regex(@"\bsets((?:\.\w+|\[(?:""[^""]*""|'[^']*'|\w+)\])+)\s*=(?!=)");
		slotPair = new Regex(@"\b(\w+)\s*=\s*gear\.(\w+)");
		anyReference = new Regex(@"\bgear\.(\w+)");
		function = new Regex(@"\bfunction\s+([\w.:]+)\s*\(");
		stringLiteral = new Regex(@"""((?:[^""\\]|\\.)*)""|'((?:[^'\\]|\\.)*)'");
		// The atomic group keeps the space after "=" from being given back, which would let "gear." slip past
		// the lookahead.
		directValue = new Regex(@"\b(main|sub|range|ranged|ammo|head|neck|left_ear|right_ear|ear1|ear2|lear|rear|body|hands|left_ring|right_ring|ring1|ring2|lring|rring|back|waist|legs|feet)\s*=(?>\s*)(?!gear\.|empty\b)([^,}\r\n]+)");
	}

	LuaGearFile(string path, List<GearDef> defs, List<GearUse> uses, HashSet<string> referencedKeys, List<string> looseReferences, List<string> directSlotValues)
	{
		Path = path;
		Defs = defs;
		Uses = uses;
		ReferencedKeys = referencedKeys;
		LooseReferences = looseReferences;
		DirectSlotValues = directSlotValues;
	}

	public static LuaGearFile Read(string path)
	{
		var text = StripComments(File.ReadAllText(path));
		var fileName = System.IO.Path.GetFileName(path);
		List<int> lineStarts = [0];
		for (var i = 0; i < text.Length; i++)
		{
			if (text[i] == '\n')
				lineStarts.Add(i + 1);
		}
		int LineOf(int index)
		{
			var found = lineStarts.BinarySearch(index);
			return found >= 0 ? found + 1 : ~found;
		}

		// Characters already explained, as a definition or a slot pair, so the last pass can report what is left.
		var claimed = new bool[text.Length];
		void Claim(int from, int to)
		{
			for (var i = from; i <= to && i < claimed.Length; i++)
				claimed[i] = true;
		}

		var defs = new List<GearDef>();
		foreach (Match match in definition.Matches(text))
		{
			var open = match.Index + match.Length - 1;
			var close = Closer(text, open, '(', ')');
			if (close < 0)
				continue;
			var inner = text.Substring(open + 1, close - open - 1);
			var name = stringLiteral.Match(inner);
			if (name.Success is false)
				continue;
			var augments = new List<string>();
			var augmentKey = Regex.Match(inner, @"\baugments\s*=\s*\{");
			if (augmentKey.Success)
			{
				var listOpen = augmentKey.Index + augmentKey.Length - 1;
				var listClose = Closer(inner, listOpen, '{', '}');
				if (listClose > listOpen)
					augments = stringLiteral.Matches(inner.Substring(listOpen, listClose - listOpen + 1)).Select(Unquote).ToList();
			}
			var bag = Regex.Match(inner, @"\bbag\s*=\s*[""'](\w+)[""']");
			defs.Add(new GearDef(match.Groups[1].Value, Unquote(name), augments, bag.Success ? bag.Groups[1].Value : null, fileName, LineOf(match.Index)));
			Claim(match.Index, close);
		}

		var uses = new List<GearUse>();
		var direct = new List<string>();
		foreach (Match match in setAssignment.Matches(text))
		{
			var setName = match.Groups[1].Value.TrimStart('.').Replace('"', '\'');
			foreach (var table in TablesAssigned(text, match.Index + match.Length))
			{
				var body = text.Substring(table.Open, table.Close - table.Open + 1);
				foreach (Match pair in slotPair.Matches(body))
				{
					uses.Add(new GearUse(pair.Groups[2].Value, pair.Groups[1].Value, setName, LineOf(table.Open + pair.Index)));
					Claim(table.Open + pair.Index, table.Open + pair.Index + pair.Length - 1);
				}
				foreach (Match value in directValue.Matches(body))
					direct.Add($"{fileName}:{LineOf(table.Open + value.Index)}: sets.{setName}: {value.Value.Trim()}");
			}
		}

		// What is left is in a hook or another function, and is listed under that function's name. Outside a set's
		// table only a slot's own name counts, so "local cape = gear.x" isn't taken for a slot called cape.
		var functions = function.Matches(text).Select(match => new NamedPosition(match.Groups[1].Value, match.Index)).ToList();
		foreach (Match pair in slotPair.Matches(text))
		{
			if (claimed[pair.Index] || Resources.SlotNames.Contains(ItemInfo.CanonicalSlot(pair.Groups[1].Value)) is false)
				continue;
			var owner = functions.LastOrDefault(candidate => candidate.Index < pair.Index);
			uses.Add(new GearUse(pair.Groups[2].Value, pair.Groups[1].Value, (owner?.Name ?? fileName) + "()", LineOf(pair.Index)));
			Claim(pair.Index, pair.Index + pair.Length - 1);
		}

		var loose = new List<string>();
		var referenced = uses.Select(use => use.Key).ToHashSet();
		foreach (Match reference in anyReference.Matches(text))
		{
			if (claimed[reference.Index])
				continue;
			referenced.Add(reference.Groups[1].Value);
			var line = LineOf(reference.Index);
			var end = line < lineStarts.Count ? lineStarts[line] : text.Length;
			loose.Add($"{fileName}:{line}: {text[lineStarts[line - 1]..end].Trim()}");
		}

		return new LuaGearFile(path, defs, uses.OrderBy(use => use.Line).ToList(), referenced, loose.Distinct().ToList(), direct);
	}

	// Lua source without its comments. Every line break stays, so line numbers still match the file.
	public static string StripComments(string source)
	{
		var result = new StringBuilder(source.Length);
		var i = 0;
		while (i < source.Length)
		{
			var c = source[i];
			if (c == '"' || c == '\'')
			{
				var end = i + 1;
				while (end < source.Length && source[end] != c && source[end] != '\n')
					end += source[end] == '\\' ? 2 : 1;
				end = Math.Min(end, source.Length - 1);
				result.Append(source, i, end - i + 1);
				i = end + 1;
			}
			else if (c == '-' && i + 1 < source.Length && source[i + 1] == '-')
			{
				// A block comment opens with --[[ or with = signs between the brackets, as in --[==[, and only the
				// bracket with as many = signs closes it.
				var level = 0;
				while (i + 3 + level < source.Length && source[i + 3 + level] == '=')
					level++;
				var block = i + 3 + level < source.Length && source[i + 2] == '[' && source[i + 3 + level] == '[';
				var closer = "]" + new string('=', level) + "]";
				var stop = block ? source.IndexOf(closer, i + 4 + level, StringComparison.Ordinal) : source.IndexOf('\n', i);
				if (stop < 0)
				{
					stop = source.Length;
				}
				else if (block)
				{
					stop += closer.Length;
				}
				result.Append('\n', source[i..stop].Count(ch => ch == '\n'));
				i = stop;
			}
			else
			{
				result.Append(c);
				i++;
			}
		}
		return result.ToString();
	}

	// The tables a set assignment gives: the one table of "sets.X = { ... }", or each table passed to
	// "sets.X = set_combine(...)". Anything else, such as "sets.X = sets.Y", names no pieces of its own.
	static List<Span> TablesAssigned(string text, int afterEquals)
	{
		var start = afterEquals;
		while (start < text.Length && char.IsWhiteSpace(text[start]))
			start++;
		var tables = new List<Span>();
		if (start >= text.Length)
			return tables;
		if (text[start] == '{')
		{
			var close = Closer(text, start, '{', '}');
			if (close > start)
				tables.Add(new Span(start, close));
			return tables;
		}
		var call = Regex.Match(text.Substring(start, Math.Min(40, text.Length - start)), @"^set_combine\s*\(");
		if (call.Success is false)
			return tables;
		var open = start + call.Length - 1;
		var end = Closer(text, open, '(', ')');
		for (var i = open + 1; i < end; i++)
		{
			if (text[i] == '"' || text[i] == '\'')
			{
				i = SkipString(text, i);
			}
			else if (text[i] == '{')
			{
				var close = Closer(text, i, '{', '}');
				if (close < 0)
					break;
				tables.Add(new Span(i, close));
				i = close;
			}
		}
		return tables;
	}

	// The index of the bracket that closes the one at open, or -1. Brackets inside strings don't count.
	static int Closer(string text, int open, char opener, char closer)
	{
		var depth = 0;
		for (var i = open; i < text.Length; i++)
		{
			var c = text[i];
			if (c == '"' || c == '\'')
			{
				i = SkipString(text, i);
			}
			else if (c == opener)
			{
				depth++;
			}
			else if (c == closer)
			{
				depth--;
				if (depth == 0)
					return i;
			}
		}
		return -1;
	}

	// The index of the quote that ends the string starting at start.
	static int SkipString(string text, int start)
	{
		var end = start + 1;
		while (end < text.Length && text[end] != text[start])
			end += text[end] == '\\' ? 2 : 1;
		return Math.Min(end, text.Length - 1);
	}

	static string Unquote(Match literal)
	{
		var body = literal.Groups[1].Success ? literal.Groups[1].Value : literal.Groups[2].Value;
		return body.Replace("\\\"", "\"").Replace("\\'", "'").Replace("\\\\", "\\");
	}

	sealed class Span
	{
		public int Open { get; }

		public int Close { get; }

		public Span(int open, int close)
		{
			Open = open;
			Close = close;
		}
	}

	sealed class NamedPosition
	{
		public string Name { get; }

		public int Index { get; }

		public NamedPosition(string name, int index)
		{
			Name = name;
			Index = index;
		}
	}
}

// A character's gear files: the library every job file includes, the character's globals and its job files.
sealed class GearFiles
{
	public string Character { get; }

	public LuaGearFile Library { get; }

	// <Character>-Globals.lua, when the character has one.
	public LuaGearFile? Globals { get; }

	// Keyed by job, as in BLU for BLU.lua.
	public IReadOnlyDictionary<string, LuaGearFile> Jobs { get; }

	GearFiles(string character, LuaGearFile library, LuaGearFile? globals, Dictionary<string, LuaGearFile> jobs)
	{
		Character = character;
		Library = library;
		Globals = globals;
		Jobs = jobs;
	}

	public static GearFiles Load(string character)
	{
		var libraryPath = Tool.InRepo("data", "common", "RahvinGS", "GearSets-Include.lua");
		if (File.Exists(libraryPath) is false)
			Tool.Fail("data/common/RahvinGS/GearSets-Include.lua is missing. Run: git submodule update --init");
		var folder = Tool.InRepo("data", character);
		if (Directory.Exists(folder) is false)
			Tool.Fail($"No folder data/{character}.");
		var globalsPath = System.IO.Path.Combine(folder, character + "-Globals.lua");
		var jobs = Directory.GetFiles(folder, "*.lua")
			.Where(Characters.IsJobFile)
			.OrderBy(path => path, StringComparer.Ordinal)
			.ToDictionary(path => System.IO.Path.GetFileNameWithoutExtension(path), LuaGearFile.Read);
		return new GearFiles(character, LuaGearFile.Read(libraryPath), File.Exists(globalsPath) ? LuaGearFile.Read(globalsPath) : null, jobs);
	}

	// The jobs a tool should cover: the ones named with --job (comma separated), or all of them.
	public IReadOnlyList<string> Select(string? jobOption)
	{
		if (jobOption is null)
			return Jobs.Keys.ToList();
		var wanted = jobOption.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Select(job => job.ToUpperInvariant()).ToList();
		foreach (var job in wanted.Where(job => Jobs.ContainsKey(job) is false))
			Tool.Fail($"No data/{Character}/{job}.lua. Job files: {string.Join(", ", Jobs.Keys)}");
		return wanted;
	}

	// Every definition a job file can use, by key. A later file's entry replaces an earlier one's, as it does when
	// GearSwap loads them: the library, then the globals, then the job file.
	public Dictionary<string, GearDef> DefsFor(string job)
	{
		var defs = new Dictionary<string, GearDef>();
		LuaGearFile?[] files = [Library, Globals, Jobs[job]];
		foreach (var def in files.SelectMany(file => file?.Defs ?? []))
			defs[def.Key] = def;
		return defs;
	}
}

// One gear.<key> = hp_gear("Name", ...) entry.
sealed class GearDef
{
	public string Key { get; }

	// As written, which may be the item's short name or its log name.
	public string Name { get; }

	// Empty when the entry names no augments, and it then matches any copy of the item.
	public IReadOnlyList<string> Augments { get; }

	// The bag the entry is pinned to, if it names one.
	public string? Bag { get; }

	public string FileName { get; }

	public int Line { get; }

	public string AugmentText => string.Join(", ", Augments);

	public GearDef(string key, string name, IReadOnlyList<string> augments, string? bag, string fileName, int line)
	{
		Key = key;
		Name = name;
		Augments = augments;
		Bag = bag;
		FileName = fileName;
		Line = line;
	}

	// Whether this export line is a copy the entry names: its augments are the entry's, exactly as exported, or the
	// entry names none and any copy will do.
	public bool Matches(ExportItem copy) => Augments.Count == 0 || Augments.SequenceEqual(copy.Augments);
}

// One "slot = gear.<key>" in a set's table or in a hook.
sealed class GearUse
{
	public string Key { get; }

	public string Slot { get; }

	// The set, without the leading "sets." and with single quotes, as in Midcast['Battery Charge']. For a hook,
	// the function's name and "()".
	public string SetName { get; }

	public int Line { get; }

	public GearUse(string key, string slot, string setName, int line)
	{
		Key = key;
		Slot = slot;
		SetName = setName;
		Line = line;
	}
}
