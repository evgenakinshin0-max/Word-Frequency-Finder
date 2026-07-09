// WordFrequency.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

class WordFrequency
{
    private HashSet<string> stopWordsEn = new HashSet<string>
    {
        "a", "an", "the", "and", "or", "but", "for", "nor", "on", "at",
        "to", "by", "in", "with", "without", "of", "per", "via", "plus",
        "minus", "up", "down", "off", "over", "under"
    };
    private HashSet<string> stopWordsRu = new HashSet<string>
    {
        "и", "в", "во", "не", "что", "он", "на", "я", "с", "со", "как",
        "а", "то", "все", "она", "так", "его", "но", "да", "ты", "к",
        "у", "же", "вы", "за", "бы", "по", "только", "ее", "мне", "было",
        "вот", "от", "меня", "еще", "нет", "о", "из", "ему", "теперь",
        "когда", "даже", "ну", "вдруг", "ли", "если", "уже", "или", "ни",
        "быть", "был", "него", "до", "вас", "нибудь", "опять", "уж", "вам",
        "ведь", "там", "потом", "себя", "ничего", "ей", "может", "они",
        "тут", "где", "есть", "надо", "ней", "для", "мы", "тебя", "их",
        "чем", "была", "сам", "чтоб", "без", "будто", "чего", "раз",
        "тоже", "себе", "под", "будет", "ж", "тогда", "кто", "этот",
        "того", "потому", "этого", "какой", "совсем", "ним", "здесь",
        "этом", "один", "почти", "мой", "тем", "чтобы", "нее", "сейчас",
        "были", "куда", "зачем", "всех", "можно", "при", "наконец",
        "сегодня", "любой", "два", "об", "другой", "хоть", "после",
        "над", "больше", "тот", "через", "эти", "нас", "про", "всего",
        "них", "какая", "много", "разве", "три", "эту", "моя", "впрочем",
        "хорошо", "свою", "этой", "перед", "иногда", "лучше", "чуть",
        "том", "нельзя", "такой", "более", "всё", "конечно", "всю",
        "между", "ваше", "начал", "свое", "свои", "ваши", "твою",
        "тобой", "тобою", "твоя", "твои", "твое", "вами", "нами"
    };

    private bool useStopWords = true;
    private int topN = 10;
    private string language = "en";

    public void SetTopN(int n) => topN = n;
    public void ToggleStopWords() => useStopWords = !useStopWords;
    public void SetLanguage(string lang) { if (lang == "en" || lang == "ru") language = lang; }

    private HashSet<string> GetStopWords() => language == "ru" ? stopWordsRu : stopWordsEn;

    public (List<(string word, int count)> top, int total, int unique) ProcessText(string text)
    {
        var words = Regex.Matches(text.ToLowerInvariant(), @"\b\w+\b")
                         .Cast<Match>()
                         .Select(m => m.Value)
                         .ToList();
        int total = words.Count;
        var stop = GetStopWords();
        var filtered = useStopWords ? words.Where(w => !stop.Contains(w)) : words;
        var freq = new Dictionary<string, int>();
        foreach (var w in filtered)
        {
            if (freq.ContainsKey(w)) freq[w]++;
            else freq[w] = 1;
        }
        var sorted = freq.OrderByDescending(kv => kv.Value).ThenBy(kv => kv.Key).ToList();
        var top = sorted.Take(topN).Select(kv => (kv.Key, kv.Value)).ToList();
        return (top, total, freq.Count);
    }

    public void Display((List<(string word, int count)> top, int total, int unique) result)
    {
        if (result.top.Count == 0)
        {
            Console.WriteLine("No words found after filtering.");
            return;
        }
        Console.WriteLine($"\nTop {result.top.Count} words (total: {result.total}, unique: {result.unique}):");
        foreach (var item in result.top)
        {
            double pct = (double)item.count / result.total * 100;
            Console.WriteLine($"  {item.word}: {item.count} ({pct:F1}%)");
        }
    }

    static void Main()
    {
        var analyzer = new WordFrequency();
        Console.WriteLine("=== Word Frequency Finder ===");
        while (true)
        {
            Console.WriteLine("\n1. Enter text manually");
            Console.WriteLine("2. Load from file");
            Console.WriteLine($"3. Set number of top words (current: {analyzer.topN})");
            Console.WriteLine($"4. Toggle stop words (currently: {(analyzer.useStopWords ? "on" : "off")})");
            Console.WriteLine($"5. Set language (current: {analyzer.language})");
            Console.WriteLine("6. Exit");
            Console.Write("Choose: ");
            string choice = Console.ReadLine()?.Trim() ?? "";
            switch (choice)
            {
                case "1":
                    Console.WriteLine("Enter your text (end with empty line):");
                    var lines = new List<string>();
                    while (true)
                    {
                        string line = Console.ReadLine() ?? "";
                        if (line == "") break;
                        lines.Add(line);
                    }
                    string text = string.Join("\n", lines);
                    if (!string.IsNullOrEmpty(text))
                    {
                        var result = analyzer.ProcessText(text);
                        analyzer.Display(result);
                    }
                    break;
                case "2":
                    Console.Write("Enter file path: ");
                    string fname = Console.ReadLine()?.Trim() ?? "";
                    if (!File.Exists(fname))
                    {
                        Console.WriteLine("File not found.");
                        break;
                    }
                    string content = File.ReadAllText(fname);
                    var res = analyzer.ProcessText(content);
                    analyzer.Display(res);
                    break;
                case "3":
                    Console.Write("Enter number of top words: ");
                    if (int.TryParse(Console.ReadLine(), out int n) && n > 0)
                        analyzer.SetTopN(n);
                    else
                        Console.WriteLine("Invalid number.");
                    break;
                case "4":
                    analyzer.ToggleStopWords();
                    Console.WriteLine("Stop words toggled.");
                    break;
                case "5":
                    Console.Write("Enter language (en/ru): ");
                    string lang = Console.ReadLine()?.Trim().ToLower() ?? "";
                    analyzer.SetLanguage(lang);
                    Console.WriteLine($"Language set to {lang}.");
                    break;
                case "6":
                    Console.WriteLine("Goodbye!");
                    return;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }
}
