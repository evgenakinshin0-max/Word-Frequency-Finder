// WordFrequency.java
import java.io.*;
import java.util.*;
import java.util.regex.*;

public class WordFrequency {
    private Set<String> stopWordsEn = new HashSet<>(Arrays.asList(
        "a", "an", "the", "and", "or", "but", "for", "nor", "on", "at",
        "to", "by", "in", "with", "without", "of", "per", "via", "plus",
        "minus", "up", "down", "off", "over", "under"
    ));
    private Set<String> stopWordsRu = new HashSet<>(Arrays.asList(
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
    ));

    private boolean useStopWords = true;
    private int topN = 10;
    private String language = "en";

    public void setTopN(int n) { topN = n; }
    public void toggleStopWords() { useStopWords = !useStopWords; }
    public void setLanguage(String lang) { if (lang.equals("en") || lang.equals("ru")) language = lang; }

    private Set<String> getStopWords() { return language.equals("ru") ? stopWordsRu : stopWordsEn; }

    public Result processText(String text) {
        Pattern p = Pattern.compile("\\b\\w+\\b", Pattern.UNICODE_CHARACTER_CLASS);
        Matcher m = p.matcher(text.toLowerCase());
        List<String> words = new ArrayList<>();
        while (m.find()) words.add(m.group());
        int total = words.size();
        Set<String> stop = getStopWords();
        List<String> filtered = new ArrayList<>();
        for (String w : words) {
            if (!useStopWords || !stop.contains(w)) filtered.add(w);
        }
        Map<String, Integer> freq = new HashMap<>();
        for (String w : filtered) {
            freq.put(w, freq.getOrDefault(w, 0) + 1);
        }
        List<Map.Entry<String, Integer>> sorted = new ArrayList<>(freq.entrySet());
        sorted.sort((a, b) -> {
            int cmp = b.getValue().compareTo(a.getValue());
            if (cmp == 0) return a.getKey().compareTo(b.getKey());
            return cmp;
        });
        List<Pair> top = new ArrayList<>();
        int limit = Math.min(topN, sorted.size());
        for (int i = 0; i < limit; i++) {
            Map.Entry<String, Integer> e = sorted.get(i);
            top.add(new Pair(e.getKey(), e.getValue()));
        }
        return new Result(top, total, freq.size());
    }

    public void display(Result result) {
        if (result.top.isEmpty()) {
            System.out.println("No words found after filtering.");
            return;
        }
        System.out.printf("\nTop %d words (total: %d, unique: %d):\n", result.top.size(), result.total, result.unique);
        for (Pair p : result.top) {
            double pct = (double) p.count / result.total * 100;
            System.out.printf("  %s: %d (%.1f%%)\n", p.word, p.count, pct);
        }
    }

    static class Pair { String word; int count; Pair(String w, int c) { word = w; count = c; } }
    static class Result { List<Pair> top; int total, unique; Result(List<Pair> t, int tot, int u) { top = t; total = tot; unique = u; } }

    public static void main(String[] args) throws IOException {
        WordFrequency analyzer = new WordFrequency();
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("=== Word Frequency Finder ===");
        while (true) {
            System.out.println("\n1. Enter text manually");
            System.out.println("2. Load from file");
            System.out.printf("3. Set number of top words (current: %d)\n", analyzer.topN);
            System.out.printf("4. Toggle stop words (currently: %s)\n", analyzer.useStopWords ? "on" : "off");
            System.out.printf("5. Set language (current: %s)\n", analyzer.language);
            System.out.println("6. Exit");
            System.out.print("Choose: ");
            String choice = reader.readLine().trim();
            switch (choice) {
                case "1":
                    System.out.println("Enter your text (end with empty line):");
                    StringBuilder sb = new StringBuilder();
                    while (true) {
                        String line = reader.readLine();
                        if (line.isEmpty()) break;
                        sb.append(line).append("\n");
                    }
                    String text = sb.toString();
                    if (!text.isEmpty()) {
                        Result res = analyzer.processText(text);
                        analyzer.display(res);
                    }
                    break;
                case "2":
                    System.out.print("Enter file path: ");
                    String fname = reader.readLine().trim();
                    try (BufferedReader fr = new BufferedReader(new FileReader(fname))) {
                        StringBuilder content = new StringBuilder();
                        String line;
                        while ((line = fr.readLine()) != null) content.append(line).append("\n");
                        Result res2 = analyzer.processText(content.toString());
                        analyzer.display(res2);
                    } catch (FileNotFoundException e) {
                        System.out.println("File not found.");
                    }
                    break;
                case "3":
                    System.out.print("Enter number of top words: ");
                    try {
                        int n = Integer.parseInt(reader.readLine().trim());
                        if (n <= 0) System.out.println("Must be positive.");
                        else analyzer.setTopN(n);
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid number.");
                    }
                    break;
                case "4":
                    analyzer.toggleStopWords();
                    System.out.println("Stop words toggled.");
                    break;
                case "5":
                    System.out.print("Enter language (en/ru): ");
                    String lang = reader.readLine().trim().toLowerCase();
                    if (lang.equals("en") || lang.equals("ru")) {
                        analyzer.setLanguage(lang);
                        System.out.printf("Language set to %s.\n", lang);
                    } else {
                        System.out.println("Invalid language.");
                    }
                    break;
                case "6":
                    System.out.println("Goodbye!");
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }
}
