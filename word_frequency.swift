// word_frequency.swift
import Foundation

class WordFrequency {
    private let stopWordsEn: Set<String> = [
        "a", "an", "the", "and", "or", "but", "for", "nor", "on", "at",
        "to", "by", "in", "with", "without", "of", "per", "via", "plus",
        "minus", "up", "down", "off", "over", "under"
    ]
    private let stopWordsRu: Set<String> = [
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
    ]
    var useStopWords = true
    var topN = 10
    var language = "en"

    private var stopWords: Set<String> {
        return language == "ru" ? stopWordsRu : stopWordsEn
    }

    func processText(_ text: String) -> (top: [(word: String, count: Int)], total: Int, unique: Int) {
        let words = text.lowercased().components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
        let total = words.count
        let filtered = useStopWords ? words.filter { !stopWords.contains($0) } : words
        var freq: [String: Int] = [:]
        for w in filtered {
            freq[w, default: 0] += 1
        }
        let sorted = freq.sorted { (a, b) -> Bool in
            if a.value == b.value { return a.key < b.key }
            return a.value > b.value
        }
        let top = sorted.prefix(topN).map { (word: $0.key, count: $0.value) }
        return (top, total, freq.count)
    }

    func display(result: (top: [(word: String, count: Int)], total: Int, unique: Int)) {
        if result.top.isEmpty {
            print("No words found after filtering.")
            return
        }
        print("\nTop \(result.top.count) words (total: \(result.total), unique: \(result.unique)):")
        for item in result.top {
            let pct = Double(item.count) / Double(result.total) * 100
            print("  \(item.word): \(item.count) (\(String(format: "%.1f", pct))%)")
        }
    }
}

func main() {
    let analyzer = WordFrequency()
    print("=== Word Frequency Finder ===")
    while true {
        print("\n1. Enter text manually")
        print("2. Load from file")
        print("3. Set number of top words (current: \(analyzer.topN))")
        print("4. Toggle stop words (currently: \(analyzer.useStopWords ? "on" : "off"))")
        print("5. Set language (current: \(analyzer.language))")
        print("6. Exit")
        print("Choose: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
        switch choice {
        case "1":
            print("Enter your text (end with empty line):")
            var lines: [String] = []
            while true {
                guard let line = readLine() else { break }
                if line.isEmpty { break }
                lines.append(line)
            }
            let text = lines.joined(separator: "\n")
            if !text.isEmpty {
                let result = analyzer.processText(text)
                analyzer.display(result: result)
            }
        case "2":
            print("Enter file path: ", terminator: "")
            guard let fname = readLine()?.trimmingCharacters(in: .whitespaces) else { break }
            let fileURL = URL(fileURLWithPath: fname)
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
                print("File not found or unreadable.")
                break
            }
            let result = analyzer.processText(content)
            analyzer.display(result: result)
        case "3":
            print("Enter number of top words: ", terminator: "")
            if let nStr = readLine(), let n = Int(nStr), n > 0 {
                analyzer.topN = n
            } else {
                print("Must be a positive integer.")
            }
        case "4":
            analyzer.useStopWords.toggle()
            print("Stop words toggled.")
        case "5":
            print("Enter language (en/ru): ", terminator: "")
            if let lang = readLine()?.trimmingCharacters(in: .whitespaces).lowercased(),
               lang == "en" || lang == "ru" {
                analyzer.language = lang
                print("Language set to \(lang).")
            } else {
                print("Invalid language.")
            }
        case "6":
            print("Goodbye!")
            return
        default:
            print("Invalid choice.")
        }
    }
}

main()
