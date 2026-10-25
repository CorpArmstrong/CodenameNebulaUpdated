using System;
using System.Collections.Generic;
using System.IO;

namespace CNNLauncher
{
    // Line-level editing of an Unreal ini. Not a dictionary: UE1 inis repeat
    // keys (Paths=, Suppress=), so everything is kept in order and only the
    // lines asked for change.
    public class IniFile
    {
        private readonly string path;
        public List<string> Lines { get; }

        public IniFile(string path)
        {
            this.path = path;
            Lines = new List<string>(File.ReadAllLines(path));
        }

        public void Save()
        {
            File.WriteAllLines(path, Lines.ToArray());
        }

        // Index range of a section's body: first line after the header, and the
        // line after the body (next header or end); -1 when absent
        private int SectionStart(string section)
        {
            for (int i = 0; i < Lines.Count; i++)
                if (Lines[i].Trim().Equals("[" + section + "]", StringComparison.OrdinalIgnoreCase))
                    return i + 1;
            return -1;
        }

        private int SectionEnd(int start)
        {
            int i = start;
            while (i < Lines.Count && !Lines[i].TrimStart().StartsWith("["))
                i++;
            return i;
        }

        public string Get(string section, string key)
        {
            int start = SectionStart(section);
            if (start < 0)
                return null;
            int end = SectionEnd(start);
            for (int i = start; i < end; i++)
                if (Lines[i].StartsWith(key + "=", StringComparison.OrdinalIgnoreCase))
                    return Lines[i].Substring(key.Length + 1);
            return null;
        }

        public void Set(string section, string key, string value)
        {
            int start = SectionStart(section);
            if (start < 0)
            {
                Lines.Add("");
                Lines.Add("[" + section + "]");
                Lines.Add(key + "=" + value);
                return;
            }
            int end = SectionEnd(start);
            for (int i = start; i < end; i++)
            {
                if (Lines[i].StartsWith(key + "=", StringComparison.OrdinalIgnoreCase))
                {
                    Lines[i] = key + "=" + value;
                    return;
                }
            }
            Lines.Insert(start, key + "=" + value);
        }
    }
}
