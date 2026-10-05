using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace GearTools;

// The Markdown the tools read as data: the tables of the gear list and the notes.
static class Markdown
{
	// The row under a table's header. It may be spaced out, and may set a column's alignment: | --- | :--- | ---: |.
	public static bool IsDelimiterRow(string line) => Regex.IsMatch(line, @"^\|(?=.*-)[\s:|-]+\|?\s*$");
}
