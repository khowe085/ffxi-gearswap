using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Text.RegularExpressions;

namespace GearTools;

// Reads a Selindrile gear file (data/<Character>/<Character>_<Job>_Gear.lua) into a SetsDto: every sets.X = ...
// assignment, the gear.x tables its slots name, and BLU's blue_magic_maps lists. It reads the text in file order; it
// doesn't run Lua, so an assignment counts wherever it is, inside an if or a function too, and a set named at run
// time, as sets.WS[ws] is, isn't seen. What it can't read it leaves out and notes. This is the only code here that
// knows the Sel framework; docs/frameworks/sel.md covers the rest of it.
static class SelReader
{
	static Regex identifier;
	static HashSet<string> keywords;
	static string[] predefined;

	static SelReader()
	{
		identifier = new Regex(@"^[A-Za-z_][A-Za-z0-9_]*$");
		// The empty sets Sel's own files make before the gear file runs: Sel-Include.lua's init_include and
		// Sel-TreasureHunter.lua.
		predefined = ["precast", "precast.FC", "precast.JA", "precast.WS", "precast.RA", "precast.Item", "midcast", "midcast.Item", "midcast.RA",
			"midcast.Pet", "idle", "resting", "engaged", "defense", "buff", "element", "passive", "weapons", "DuskIdle", "DayIdle", "NightIdle",
			"TreasureHunter"];
		keywords = ["and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"];
	}

	// The files Sel loads ahead of a character's gear file, in Sel's order (Sel-Include.lua's init_include): the job
	// file, User-Globals, the character's Globals, Items and Crafting, then User-<JOB>. Only those that exist.
	public static IReadOnlyList<string> LoadedBefore(string gearFile, string character, string job)
	{
		var folder = Path.GetDirectoryName(Path.GetFullPath(gearFile))!;
		string[] candidates = [
			Tool.InRepo("data", job + ".lua"),
			Tool.InRepo("data", "User", "User-Globals.lua"),
			Path.Combine(folder, character + "-Globals.lua"),
			Path.Combine(folder, character + "-Items.lua"),
			Path.Combine(folder, character + "_Crafting.lua"),
			Tool.InRepo("data", "User", "User-" + job.ToUpperInvariant() + ".lua"),
		];
		return candidates.Where(File.Exists).ToList();
	}

	// The character and job a gear file is named for, or null for a file named otherwise.
	public static Match NameOf(string gearFile) => Regex.Match(Path.GetFileName(gearFile), @"^(?<who>[^_]+)_(?<job>[A-Za-z]{3})_[Gg]ear\.lua$");

	// The sets in a gear file, built on what the files loaded before it define. Of those files' sets only the ones
	// assigned outside any function or block are read, as Vanar-Items.lua's sets.TreasureHunter: the rest are made at
	// run time and aren't gear sets to check.
	public static SelRead Read(string gearFile, string character, string job, IEnumerable<string> loadedBefore)
	{
		var reading = new Reading(character, job.ToUpperInvariant());
		foreach (var file in loadedBefore)
			reading.Take(file, topLevelSetsOnly: true);
		reading.Take(gearFile, topLevelSetsOnly: false);
		return reading.Finish();
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
			else if (c == '[' && LongBracket(source, i) is int equalSigns)
			{
				// A long string, [[...]] or [==[...]==], holds "--" as text.
				var closer = "]" + new string('=', equalSigns) + "]";
				var stop = source.IndexOf(closer, i + equalSigns + 2, StringComparison.Ordinal);
				stop = stop < 0 ? source.Length : stop + closer.Length;
				result.Append(source, i, stop - i);
				i = stop;
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

	// The number of = signs in a long bracket that opens at start, as in [[ or [==[, or null when none opens there.
	static int? LongBracket(string source, int start)
	{
		var level = 0;
		while (start + 1 + level < source.Length && source[start + 1 + level] == '=')
			level++;
		return start + 1 + level < source.Length && source[start + 1 + level] == '[' ? level : null;
	}

	// A set's name in the DTO: its path under sets, written as Lua writes it, so sets.midcast['Blue Magic'].Buff is
	// midcast['Blue Magic'].Buff. A key that is a plain name always takes the dot form, whichever form the file used.
	public static string SetName(IReadOnlyList<string> keys)
	{
		var name = new StringBuilder();
		foreach (var key in keys)
		{
			if (IsName(key))
			{
				if (name.Length > 0)
					name.Append('.');
				name.Append(key);
			}
			else if (key.StartsWith(NumberMark))
			{
				name.Append($"[{key[1..]}]");
			}
			else
			{
				var quote = key.Contains('\'') && key.Contains('"') is false ? '"' : '\'';
				var escaped = key.Replace("\\", "\\\\").Replace(quote.ToString(), "\\" + quote);
				name.Append($"[{quote}{escaped}{quote}]");
			}
		}
		return name.ToString();
	}

	// Marks a key written as a number, as the 1 in sets.weapons[1], apart from the string key '1'.
	const char NumberMark = '\u0001';

	static bool IsName(string key) => identifier.IsMatch(key) && keywords.Contains(key) is false;

	// The state of one read: what the files so far define, in file order.
	sealed class Reading
	{
		string character;
		string job;
		Dictionary<string, LuaValue> gear;
		Dictionary<string, SetDto> sets;
		List<SetDto> order;
		// The sets Sel's own files define that no file read has defined again. They are empty, so building on one
		// takes nothing from it, and they aren't written to the sets file.
		HashSet<string> seeded;
		// The file each set was last defined in. Redefining another file's set, as a gear file does an Items set, is
		// what Sel expects, so only a second definition in one file is noted.
		Dictionary<string, string> definedIn;
		// The branches of the ifs each set's last definition sits in, by the if's number.
		Dictionary<string, IReadOnlyList<(int If, int Branch)>> definedAt;
		// Each alias, as sets.B = sets.A makes one, with the set it is the same table as, in the order they were made.
		List<(string Alias, string Target)> aliases;
		Dictionary<string, List<string>> lists;
		List<string> notes;
		// What is worth knowing but no mistake, as a set defined again on itself.
		List<string> info;
		string fileName;
		int line;

		public Reading(string character, string job)
		{
			this.character = character;
			this.job = job;
			gear = [];
			sets = [];
			order = [];
			lists = [];
			notes = [];
			info = [];
			fileName = "";
			definedIn = [];
			definedAt = [];
			aliases = [];
			seeded = [.. predefined];
			foreach (var name in predefined)
				sets[name] = new SetDto { Name = name };
		}

		public void Take(string path, bool topLevelSetsOnly)
		{
			fileName = Path.GetFileName(path);
			var tokens = Lexer.Read(StripComments(File.ReadAllText(path)));
			var parser = new Parser(tokens);
			var assignments = parser.Assignments();
			foreach (var unread in parser.Unread.Where(unread => topLevelSetsOnly is false || unread.Root != "sets" || unread.TopLevel))
			{
				line = unread.Line;
				Note(unread.Message);
			}
			foreach (var assignment in assignments)
			{
				line = assignment.Line;
				var root = assignment.Target[0];
				if (root == "gear")
				{
					gear[string.Join(".", assignment.Target)] = assignment.Value;
				}
				else if (root == "blue_magic_maps")
				{
					TakeList(assignment);
				}
				else if (topLevelSetsOnly is false || assignment.TopLevel)
				{
					TakeSet(assignment);
				}
			}
		}

		public SelRead Finish()
		{
			var read = Current();
			read.SpellSets = job == "BLU" ? SpellSets() : null;
			return new SelRead(read, notes, info);
		}

		// The blue spells with a set of their own, where Sel's midcast walk (select_specific_set) reaches one: a set named
		// for the spell under sets.midcast; failing that, when no set under sets.midcast is named for one of the spell's
		// lists (its spell map, which Sel tries next), a set named for the spell under sets.midcast['Blue Magic']. Null
		// when none has.
		Dictionary<string, string>? SpellSets()
		{
			var own = new Dictionary<string, string>();
			bool Defined(string name) => sets.ContainsKey(name) && seeded.Contains(name) is false;
			foreach (var spell in Resources.BlueSpells().Distinct())
			{
				var top = SetName(["midcast", spell]);
				var underSkill = SetName(["midcast", "Blue Magic", spell]);
				var mapFirst = lists.Where(list => list.Value.Contains(spell)).Any(list => Defined(SetName(["midcast", list.Key])));
				if (Defined(top))
				{
					own[spell] = top;
				}
				else if (mapFirst is false && Defined(underSkill))
				{
					own[spell] = underSkill;
				}
			}
			return own.Count > 0 ? own : null;
		}

		SetsDto Current() => new() { Character = character, Job = job, Sets = order, SpellLists = lists.Count > 0 ? lists : null };

		void TakeList(Assignment assignment)
		{
			var value = assignment.Value;
			if (value.Kind == LuaKind.Call && value.Text == "S" && value.Items.Count == 1)
				value = value.Items[0];
			if (assignment.Target.Count != 2 || value.Kind != LuaKind.Table || value.Fields.Any(field => field.Key is not null || field.Value.Kind != LuaKind.String))
			{
				Note($"{string.Join(".", assignment.Target)} isn't a list of spell names, so it is left out");
				return;
			}
			lists[assignment.Target[1]] = value.Fields.Select(field => field.Value.Text).ToList();
		}

		void TakeSet(Assignment assignment)
		{
			var written = SetName(assignment.Target.Skip(1).ToList());
			// Assigning to an alias itself gives it a table of its own; a set inside one is inside its target.
			var name = aliases.Any(alias => alias.Alias == written) ? written : Canonical(written);
			var full = FullName(written);
			var set = new SetDto { Name = name };
			var value = assignment.Value;
			if (value.Kind == LuaKind.Table)
			{
				set.Slots = Slots(full, value);
			}
			else if (value.Kind == LuaKind.Path && value.Path[0] == "sets")
			{
				// sets.B = sets.A makes B the same table as A, not a copy.
				var target = Canonical(SetName(value.Path.Skip(1).ToList()));
				if (target == name)
					return;
				if (sets.ContainsKey(target) is false)
				{
					Note($"{full} is {Describe(value)}, which no file read defines, so the base is left out");
				}
				else
				{
					if (seeded.Remove(target))
						order.Add(sets[target]);
					set.AliasOf = target;
				}
			}
			else if (value.Kind == LuaKind.Call && value.Text == "set_combine")
			{
				// set_combine(set_combine(A, t1), t2) is set_combine(A, t1, t2): an inner call's arguments take its
				// place, so its base stays the set's base and its tables stay under the outer ones.
				var parts = Arguments(value).ToList();
				for (var i = 0; i < parts.Count; i++)
				{
					var part = parts[i];
					if (part.Kind == LuaKind.Table)
					{
						foreach (var slot in Slots(full, part))
							set.Slots[slot.Key] = slot.Value;
					}
					else if (i == 0 && part.Kind == LuaKind.Path && part.Path[0] == "sets")
					{
						set.Base = Base(full, part, "is built on");
					}
					else if (part.Kind == LuaKind.Path && part.Path[0] == "sets" && seeded.Contains(Canonical(SetName(part.Path.Skip(1).ToList()))))
					{
					}
					else if (part.Kind == LuaKind.Path && part.Path[0] == "sets" && sets.ContainsKey(Canonical(SetName(part.Path.Skip(1).ToList()))))
					{
						// A later set in set_combine goes over the ones before it. The DTO has room for one base, so
						// the later set's pieces become this set's own.
						var resolved = Dto.Resolve(Current(), Canonical(SetName(part.Path.Skip(1).ToList())));
						foreach (var slot in resolved)
							set.Slots[slot.Key] = slot.Value;
					}
					else
					{
						Note($"{full}: set_combine takes {Describe(part)}, which no file read defines as a set, so it is left out");
					}
				}
			}
			else
			{
				Note($"{full} = {Describe(value)} isn't a table or set_combine, so the set is left out");
				return;
			}
			if (sets.TryGetValue(name, out var earlier))
			{
				var wasSeeded = seeded.Remove(name);
				if (wasSeeded is false && definedIn.GetValueOrDefault(name) == fileName)
				{
					// sets.x = set_combine(sets.x, {...}) adds to a set, as Sel's files often do.
					var onItself = value.Kind == LuaKind.Call && value.Text == "set_combine" && Arguments(value).FirstOrDefault() is { Kind: LuaKind.Path } first
						&& first.Path[0] == "sets" && Canonical(SetName(first.Path.Skip(1).ToList())) == name;
					// Definitions in two branches of one if never both run.
					var otherBranch = definedAt.TryGetValue(name, out var before)
						&& before.Any(earlierIf => assignment.Branches.Any(thisIf => thisIf.If == earlierIf.If && thisIf.Branch != earlierIf.Branch));
					if (otherBranch)
					{
						info.Add($"{fileName}:{line}: {full} is defined in another branch of one if; the last definition is the one read");
					}
					else if (onItself)
					{
						info.Add($"{fileName}:{line}: {full} is defined a second time, built on itself; the last definition is the one read");
					}
					else
					{
						Note($"{full} is defined a second time; the last definition is the one read");
					}
				}
				aliases.RemoveAll(alias => alias.Alias == name);
				// An alias of the set still holds the old table, and the sets inside it, once the name is given a new
				// one; so does an alias of a set inside it.
				var handedOver = HandOver(name, set);
				if (handedOver is false)
				{
					foreach (var inside in order.Where(other => Dto.Inside(other.Name, name)).OrderBy(other => other.Name.Length).ToList())
					{
						if (sets.ContainsKey(inside.Name))
							HandOver(inside.Name, set);
					}
				}
				// The assignment puts a new table where the old one was, so the sets kept inside the old one (such as
				// sets.idle.DT under sets.idle) go with it: set_combine copies slots only (set_merge and unify_slots
				// in helper_functions.lua).
				var dropped = order.Where(other => Dto.Inside(other.Name, name)).ToList();
				var replaced = (handedOver ? dropped : dropped.Append(earlier)).ToDictionary(other => other.Name);
				// Lua copied a replaced set into each set built on it, this one included, so they keep its pieces:
				// each takes the replaced set's base and its slots under their own, until its base is one that stays.
				foreach (var built in order.Append(set).Where(other => replaced.Values.Contains(other) is false))
				{
					while (built.Base is not null && replaced.TryGetValue(built.Base, out var gone))
					{
						built.Base = gone.Base;
						foreach (var slot in gone.Slots.Where(slot => built.Slots.ContainsKey(slot.Key) is false))
							built.Slots[slot.Key] = slot.Value;
					}
				}
				foreach (var gone in dropped)
				{
					Note($"{FullName(gone.Name)} is dropped: defining {full} again replaces the table that held it");
					order.Remove(gone);
					sets.Remove(gone.Name);
					aliases.RemoveAll(alias => alias.Alias == gone.Name);
				}
				if (wasSeeded)
				{
					order.Add(set);
				}
				else
				{
					order[order.IndexOf(earlier)] = set;
				}
			}
			else
			{
				order.Add(set);
			}
			sets[name] = set;
			definedIn[name] = fileName;
			definedAt[name] = assignment.Branches;
			if (set.AliasOf is not null)
				aliases.Add((name, set.AliasOf));
		}

		// The set a name reaches: one inside an alias, or the alias itself, is inside the alias's target.
		string Canonical(string name)
		{
			foreach (var (alias, target) in aliases.OrderByDescending(alias => alias.Alias.Length))
			{
				if (name == alias)
					return target;
				if (Dto.Inside(name, alias))
					return target + name[alias.Length..];
			}
			return name;
		}

		// When name is given a new table, its first alias becomes the set that holds the old one: it takes the old
		// set's base and slots, the sets inside the old one move inside it, and every other reference follows, the
		// set being defined (pending) too: sets.A = set_combine(sets.A, ...) is built on the old table. False when no
		// alias names it.
		bool HandOver(string name, SetDto pending)
		{
			var heir = aliases.FirstOrDefault(alias => alias.Target == name).Alias;
			if (heir is null)
				return false;
			var old = sets[name];
			var heirSet = sets[heir];
			heirSet.AliasOf = null;
			heirSet.Base = old.Base;
			heirSet.Slots = new Dictionary<string, PieceDto>(old.Slots);
			aliases.RemoveAll(alias => alias.Alias == heir);
			string Moved(string other) => other == name ? heir : Dto.Inside(other, name) ? heir + other[name.Length..] : other;
			foreach (var inside in order.Where(other => Dto.Inside(other.Name, name)).ToList())
			{
				var moved = Moved(inside.Name);
				sets.Remove(inside.Name);
				sets[moved] = inside;
				if (definedIn.Remove(inside.Name, out var file))
					definedIn[moved] = file;
				if (definedAt.Remove(inside.Name, out var branches))
					definedAt[moved] = branches;
				inside.Name = moved;
			}
			aliases = aliases.Select(alias => (Moved(alias.Alias), Moved(alias.Target))).ToList();
			foreach (var other in order.Append(pending).Distinct())
			{
				if (other.AliasOf is not null)
					other.AliasOf = Moved(other.AliasOf);
				if (other.Base is not null)
					other.Base = Moved(other.Base);
			}
			return true;
		}

		static IEnumerable<LuaValue> Arguments(LuaValue call) =>
			call.Items.SelectMany(item => item.Kind == LuaKind.Call && item.Text == "set_combine" ? Arguments(item) : [item]);

		string? Base(string full, LuaValue path, string verb)
		{
			var name = Canonical(SetName(path.Path.Skip(1).ToList()));
			// One of Sel's empty sets gives nothing to build on.
			if (seeded.Contains(name))
				return null;
			if (sets.ContainsKey(name))
				return name;
			Note($"{full} {verb} {Describe(path)}, which no file read defines, so the base is left out");
			return null;
		}

		Dictionary<string, PieceDto> Slots(string full, LuaValue table)
		{
			var slots = new Dictionary<string, PieceDto>();
			// The name each slot was given, to tell when two names fill one slot.
			var named = new Dictionary<string, string>();
			foreach (var field in table.Fields)
			{
				if (field.Key is null)
				{
					Note($"{full}: an entry with no slot, {Describe(field.Value)}, is left out");
					continue;
				}
				var slot = ItemInfo.CanonicalSlot(field.Key);
				if (Resources.SlotNames.Contains(slot) is false)
				{
					Note($"{full}: {field.Key} isn't a slot, so it is left out");
					continue;
				}
				if (named.TryGetValue(slot, out var earlierName))
					Note($"{full}: {earlierName} and {field.Key} both fill {slot}; the last one, {field.Key}, is read");
				named[slot] = field.Key;
				var piece = Piece(full, field.Key, field.Value, []);
				if (piece is not null)
					slots[slot] = piece;
			}
			return slots;
		}

		// The piece a slot's value names: an item name, empty, a {name=...} table or a gear entry that holds one.
		PieceDto? Piece(string full, string slot, LuaValue value, HashSet<string> followed)
		{
			// GearSwap's expand_entry (equip_processing.lua) reads "" as no item, so the slot is neither equipped nor
			// taken off; {name=""} names no item it can find. The DTO has no way to say that.
			if (value.Kind == LuaKind.String && value.Text.Length == 0)
			{
				Note($"{full}: {slot} is \"\", which GearSwap equips nothing for and takes nothing off for, so the slot is left out");
				return null;
			}
			if (value.Kind == LuaKind.String)
				return new PieceDto { Item = value.Text };
			if (value.Kind == LuaKind.Path && value.Path.Count == 1 && value.Path[0] == "empty")
				return new PieceDto { Item = Dto.Empty };
			if (value.Kind == LuaKind.Path && value.Path[0] == "gear")
			{
				var key = string.Join(".", value.Path);
				if (gear.TryGetValue(key, out var entry) is false)
				{
					Note($"{full}: {slot} is {key}, which no file read defines, so the slot is left out");
					return null;
				}
				if (followed.Add(key) is false)
				{
					Note($"{full}: {slot} is {key}, which names itself, so the slot is left out");
					return null;
				}
				return Piece(full, slot, entry, followed);
			}
			if (value.Kind == LuaKind.Table)
			{
				var name = value.Fields.FirstOrDefault(field => field.Key == "name" && field.Value.Kind == LuaKind.String)?.Value.Text;
				if (name is null)
				{
					Note($"{full}: {slot} is a table with no name, so the slot is left out");
					return null;
				}
				if (name.Length == 0)
				{
					Note($"{full}: {slot} is {{name=\"\"}}, which GearSwap equips nothing for and takes nothing off for, so the slot is left out");
					return null;
				}
				var augments = value.Fields.FirstOrDefault(field => field.Key == "augments" && field.Value.Kind == LuaKind.Table)?.Value;
				var bag = value.Fields.FirstOrDefault(field => field.Key == "bag" && field.Value.Kind == LuaKind.String)?.Value.Text;
				return new PieceDto
				{
					Item = name,
					Augments = augments?.Fields.Where(field => field.Value.Kind == LuaKind.String).Select(field => field.Value.Text).ToList(),
					Bag = bag,
				};
			}
			Note($"{full}: {slot} is {Describe(value)}, which this reader can't follow, so the slot is left out");
			return null;
		}

		void Note(string message) => notes.Add($"{fileName}:{line}: {message}");

		static string FullName(string name) => name.StartsWith('[') ? "sets" + name : "sets." + name;

		static string Describe(LuaValue value) => value.Kind switch
		{
			LuaKind.String => $"\"{value.Text}\"",
			LuaKind.Path => value.Path[0] == "sets" ? FullName(SetName(value.Path.Skip(1).ToList())) : string.Join(".", value.Path),
			LuaKind.Call => value.Text + "(...)",
			LuaKind.Table => "a table",
			_ => value.Text,
		};
	}

	enum LuaKind
	{
		String,
		Number,
		Path,
		Table,
		Call,
		Other,
	}

	// A value as far as the reader follows one. A path is a chain of names and string keys, as gear.x or
	// sets.midcast['Blue Magic']; a call keeps its function's name in Text and its arguments in Items.
	sealed class LuaValue
	{
		public LuaKind Kind { get; }

		public string Text { get; }

		public IReadOnlyList<string> Path { get; }

		public IReadOnlyList<LuaField> Fields { get; }

		public IReadOnlyList<LuaValue> Items { get; }

		LuaValue(LuaKind kind, string text, IReadOnlyList<string> path, IReadOnlyList<LuaField> fields, IReadOnlyList<LuaValue> items)
		{
			Kind = kind;
			Text = text;
			Path = path;
			Fields = fields;
			Items = items;
		}

		public static LuaValue Simple(LuaKind kind, string text) => new(kind, text, [], [], []);

		public static LuaValue OfPath(IReadOnlyList<string> path) => new(LuaKind.Path, string.Join(".", path), path, [], []);

		public static LuaValue OfTable(IReadOnlyList<LuaField> fields) => new(LuaKind.Table, "", [], fields, []);

		public static LuaValue OfCall(string function, IReadOnlyList<LuaValue> arguments) => new(LuaKind.Call, function, [], [], arguments);
	}

	// One entry of a table: Key is null for an entry given by position.
	sealed class LuaField
	{
		public string? Key { get; }

		public LuaValue Value { get; }

		public LuaField(string? key, LuaValue value)
		{
			Key = key;
			Value = value;
		}
	}

	// A change the reader passed over, by the root it changes (sets, gear or blue_magic_maps).
	sealed class UnreadChange
	{
		public string Root { get; }

		public int Line { get; }

		public string Message { get; }

		// Outside any function or block.
		public bool TopLevel { get; }

		public UnreadChange(string root, int line, string message, bool topLevel)
		{
			Root = root;
			Line = line;
			Message = message;
			TopLevel = topLevel;
		}
	}

	sealed class Assignment
	{
		public IReadOnlyList<string> Target { get; }

		public LuaValue Value { get; }

		public int Line { get; }

		// Outside any function or block, so it runs as the file loads.
		public bool TopLevel { get; }

		// The ifs it sits in, each by its number in the file and the branch it is in (0 for then, 1 for the first
		// elseif or else after it, and so on).
		public IReadOnlyList<(int If, int Branch)> Branches { get; }

		public Assignment(IReadOnlyList<string> target, LuaValue value, int line, bool topLevel, IReadOnlyList<(int If, int Branch)> branches)
		{
			Target = target;
			Value = value;
			Line = line;
			TopLevel = topLevel;
			Branches = branches;
		}
	}

	enum TokenKind
	{
		Name,
		String,
		Number,
		Symbol,
	}

	sealed class Token
	{
		public TokenKind Kind { get; }

		public string Text { get; }

		public int Line { get; }

		public Token(TokenKind kind, string text, int line)
		{
			Kind = kind;
			Text = text;
			Line = line;
		}
	}

	static class Lexer
	{
		// Lua source with its comments already stripped.
		public static List<Token> Read(string source)
		{
			var tokens = new List<Token>();
			var line = 1;
			var i = 0;
			while (i < source.Length)
			{
				var c = source[i];
				if (c == '\n')
				{
					line++;
					i++;
				}
				else if (char.IsWhiteSpace(c))
				{
					i++;
				}
				else if (c == '"' || c == '\'')
				{
					var text = new StringBuilder();
					var end = i + 1;
					while (end < source.Length && source[end] != c && source[end] != '\n')
					{
						if (source[end] == '\\' && end + 1 < source.Length)
						{
							text.Append(source[end + 1]);
							end += 2;
						}
						else
						{
							text.Append(source[end]);
							end++;
						}
					}
					tokens.Add(new Token(TokenKind.String, text.ToString(), line));
					// A string left open ends at its line's end, and the line break still counts.
					i = end < source.Length && source[end] == '\n' ? end : end + 1;
				}
				else if (c == '[' && LongBracket(source, i) is int level)
				{
					var closer = "]" + new string('=', level) + "]";
					var start = i + level + 2;
					var stop = source.IndexOf(closer, start, StringComparison.Ordinal);
					if (stop < 0)
						stop = source.Length;
					tokens.Add(new Token(TokenKind.String, source[start..stop], line));
					line += source[i..stop].Count(ch => ch == '\n');
					i = Math.Min(source.Length, stop + closer.Length);
				}
				else if (char.IsLetter(c) || c == '_')
				{
					var end = i;
					while (end < source.Length && (char.IsLetterOrDigit(source[end]) || source[end] == '_'))
						end++;
					tokens.Add(new Token(TokenKind.Name, source[i..end], line));
					i = end;
				}
				else if (char.IsDigit(c))
				{
					var end = i;
					while (end < source.Length && (char.IsLetterOrDigit(source[end]) || source[end] == '.'))
						end++;
					tokens.Add(new Token(TokenKind.Number, source[i..end], line));
					i = end;
				}
				else
				{
					// The two-character operators that hold a = or a ., so neither is taken for an assignment or a
					// path step.
					var pair = i + 1 < source.Length ? source.Substring(i, 2) : "";
					var symbol = pair is "==" or "~=" or "<=" or ">=" or ".." ? pair : c.ToString();
					tokens.Add(new Token(TokenKind.Symbol, symbol, line));
					i += symbol.Length;
				}
			}
			return tokens;
		}
	}

	// Finds the assignments to sets, gear and blue_magic_maps among the tokens, and reads each value.
	sealed class Parser
	{
		static string[] roots = ["sets", "gear", "blue_magic_maps"];

		List<Token> tokens;
		int position;
		// The functions and blocks the search is inside, innermost last, and how many while or for headers wait for
		// their do. An if keeps its number and the branch the search is in.
		List<Block> blocks;
		int ifs;
		int loopHeaders;

		// What the search passed over that changes a set or a list in a way the reader can't follow.
		public List<UnreadChange> Unread { get; }

		public Parser(List<Token> tokens)
		{
			this.tokens = tokens;
			blocks = [];
			Unread = [];
		}

		public List<Assignment> Assignments()
		{
			var found = new List<Assignment>();
			while (position < tokens.Count)
			{
				var token = tokens[position];
				if (token.Kind == TokenKind.Name)
					Nest(token.Text);
				// A root after a dot or a colon is a field of something else, as in player.sets.
				var follows = position > 0 && (IsSymbol(".", -1) || IsSymbol(":", -1));
				if (token.Kind != TokenKind.Name || roots.Contains(token.Text) is false || follows)
				{
					position++;
					continue;
				}
				var start = position;
				var target = Path();
				if (target is not null && target.Count >= 2 && IsSymbol("="))
				{
					var line = tokens[position].Line;
					var topLevel = blocks.Count == 0;
					var branches = blocks.Where(block => block.If > 0).Select(block => (block.If, block.Branch)).ToList();
					position++;
					var from = position;
					var value = Value();
					// A value can hold a function, as sets.x = function() ... end does: its blocks count too, or the
					// end the search meets after it would close the block around the assignment.
					foreach (var inside in tokens.Skip(from).Take(position - from).Where(inside => inside.Kind == TokenKind.Name))
						Nest(inside.Text);
					found.Add(new Assignment(target, value, line, topLevel, branches));
					continue;
				}
				if (target is not null && target.Count >= 2 && IsSymbol(":") && Peek(1)?.Kind == TokenKind.Name && IsSymbol("(", 2))
				{
					Unread.Add(new UnreadChange(token.Text, tokens[position].Line,
						$"{string.Join(".", target)}:{tokens[position + 1].Text}(...) changes the list in a way this reader can't follow, so the list read may not be the one the game uses", blocks.Count == 0));
				}
				else if (target is null && ComputedTarget(start) is { } computed)
				{
					Unread.Add(new UnreadChange(token.Text, tokens[position].Line,
						$"{computed} is named at run time, so this reader can't read it and the set is left out", blocks.Count == 0));
				}
				position = start + 1;
			}
			return found;
		}

		// Lua's blocks: function, if, while, for and repeat open one, and so does a do that isn't a loop's; end and
		// until close one. elseif and else start the if's next branch.
		void Nest(string keyword)
		{
			switch (keyword)
			{
				case "if":
					blocks.Add(new Block(++ifs));
					break;
				case "elseif" or "else" when blocks.Count > 0:
					blocks[^1].Branch++;
					break;
				case "function" or "repeat":
					blocks.Add(new Block(0));
					break;
				case "while" or "for":
					blocks.Add(new Block(0));
					loopHeaders++;
					break;
				case "do" when loopHeaders > 0:
					loopHeaders--;
					break;
				case "do":
					blocks.Add(new Block(0));
					break;
				case "end" or "until" when blocks.Count > 0:
					blocks.RemoveAt(blocks.Count - 1);
					break;
			}
		}

		// If is the if's number, from 1, or 0 for any other block.
		sealed class Block
		{
			public int If { get; }

			public int Branch { get; set; }

			public Block(int ifNumber)
			{
				If = ifNumber;
			}
		}

		Token? Peek(int ahead = 0) => position + ahead >= 0 && position + ahead < tokens.Count ? tokens[position + ahead] : null;

		bool IsSymbol(string text, int ahead = 0) => Peek(ahead) is { Kind: TokenKind.Symbol } token && token.Text == text;

		// A chain of names and string keys from the name at the current token, as sets.precast['FC'].Utsusemi. Null when
		// it takes a key computed at run time, as sets.WS[ws] does: such a name can't be known from the text.
		List<string>? Path()
		{
			var path = new List<string> { tokens[position].Text };
			position++;
			while (true)
			{
				if (IsSymbol(".") && Peek(1)?.Kind == TokenKind.Name)
				{
					path.Add(tokens[position + 1].Text);
					position += 2;
				}
				else if (IsSymbol("[") && Peek(1)?.Kind is TokenKind.String or TokenKind.Number && IsSymbol("]", 2))
				{
					var key = tokens[position + 1];
					path.Add(key.Kind == TokenKind.Number ? NumberMark + key.Text : key.Text);
					position += 3;
				}
				else if (IsSymbol("["))
				{
					return null;
				}
				else
				{
					return path;
				}
			}
		}

		// Reads one value. Of an expression such as "a or b" it keeps the first operand; the rest is skipped by the
		// search for the next assignment.
		LuaValue Value()
		{
			var token = Peek();
			if (token is null)
				return LuaValue.Simple(LuaKind.Other, "");
			if (token.Kind == TokenKind.String)
			{
				position++;
				return LuaValue.Simple(LuaKind.String, token.Text);
			}
			if (token.Kind == TokenKind.Number)
			{
				position++;
				return LuaValue.Simple(LuaKind.Number, token.Text);
			}
			if (IsSymbol("{"))
				return Table();
			if (token.Kind == TokenKind.Name)
			{
				var path = Path();
				if (path is null)
				{
					SkipBracket();
					return LuaValue.Simple(LuaKind.Other, token.Text + "[...]");
				}
				var function = string.Join(".", path);
				if (IsSymbol("("))
				{
					position++;
					var arguments = new List<LuaValue>();
					while (position < tokens.Count && IsSymbol(")") is false)
					{
						arguments.Add(Value());
						if (IsSymbol(","))
						{
							position++;
						}
						else if (IsSymbol(")") is false)
						{
							SkipTo(")");
							if (IsSymbol(","))
								position++;
						}
					}
					if (IsSymbol(")"))
						position++;
					return LuaValue.OfCall(function, arguments);
				}
				// S{...} is a call with a table for its one argument.
				if (IsSymbol("{"))
					return LuaValue.OfCall(function, [Table()]);
				return LuaValue.OfPath(path);
			}
			position++;
			return LuaValue.Simple(LuaKind.Other, token.Text);
		}

		LuaValue Table()
		{
			position++;
			var fields = new List<LuaField>();
			while (position < tokens.Count && IsSymbol("}") is false)
			{
				string? key = null;
				if (Peek()?.Kind == TokenKind.Name && IsSymbol("=", 1))
				{
					key = tokens[position].Text;
					position += 2;
				}
				else if (IsSymbol("[") && Peek(1)?.Kind == TokenKind.String && IsSymbol("]", 2) && IsSymbol("=", 3))
				{
					key = tokens[position + 1].Text;
					position += 4;
				}
				fields.Add(new LuaField(key, Value()));
				if (IsSymbol(",") || IsSymbol(";"))
				{
					position++;
				}
				else if (IsSymbol("}") is false)
				{
					SkipTo("}");
					if (IsSymbol(",") || IsSymbol(";"))
						position++;
				}
			}
			if (IsSymbol("}"))
				position++;
			return LuaValue.OfTable(fields);
		}

		// Moves to the next "," or the given closer at this depth, past whatever brackets lie between.
		void SkipTo(string closer)
		{
			var depth = 0;
			while (position < tokens.Count)
			{
				if (IsSymbol("(") || IsSymbol("{") || IsSymbol("["))
				{
					depth++;
				}
				else if (IsSymbol(")") || IsSymbol("}") || IsSymbol("]"))
				{
					if (depth == 0)
						return;
					depth--;
				}
				else if (depth == 0 && (IsSymbol(",") || IsSymbol(";")))
				{
					return;
				}
				position++;
			}
		}

		// After a path stopped at a key computed at run time: the path as written, with "[...]" for each such key, when
		// an assignment follows it, or null. Leaves the position at the "=".
		string? ComputedTarget(int start)
		{
			var written = new StringBuilder(string.Concat(tokens.Skip(start).Take(position - start).Select(token => token.Kind == TokenKind.String ? $"'{token.Text}'" : token.Text)));
			while (IsSymbol("[") || (IsSymbol(".") && Peek(1)?.Kind == TokenKind.Name))
			{
				if (IsSymbol("["))
				{
					SkipBracket();
					written.Append("[...]");
				}
				else
				{
					written.Append('.').Append(tokens[position + 1].Text);
					position += 2;
				}
			}
			return IsSymbol("=") ? written.ToString() : null;
		}

		void SkipBracket()
		{
			if (IsSymbol("[") is false)
				return;
			position++;
			SkipTo("]");
			if (IsSymbol("]"))
				position++;
		}
	}
}

// What SelReader read from a gear file, and what it couldn't read.
sealed class SelRead
{
	public SetsDto Sets { get; }

	// Each as <file>:<line>: <what was left out and why>.
	public IReadOnlyList<string> Notes { get; }

	// Each as a note is, for what is no mistake: these don't count toward sel-sets' exit code.
	public IReadOnlyList<string> Info { get; }

	public SelRead(SetsDto sets, IReadOnlyList<string> notes, IReadOnlyList<string> info)
	{
		Sets = sets;
		Notes = notes;
		Info = info;
	}
}
