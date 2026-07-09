# 📊 Word Frequency Finder – Multi‑Language Edition

A sophisticated **word frequency analyzer** that counts how often each word appears in a given text, filters out common stop words, and displays the top N results.  
Built in **7 programming languages** – perfect for learning or NLP projects.

## ✨ Features
- **Case‑insensitive** – converts all words to lowercase.
- **Punctuation removal** – strips punctuation and special characters.
- **Stop words filter** – ignores common words (e.g., "the", "a", "and") – customisable.
- **Top N results** – choose how many most frequent words to display (default 10).
- **Input sources** – read from standard input (type or paste) or load from a text file.
- **Detailed output** – shows word, frequency, and percentage of total words.
- **Multi‑language support** – works with English and Russian alphabets (stop word lists for both).

## 🗂 Languages & Files
| Language          | File                         |
|-------------------|------------------------------|
| Python            | `word_frequency.py`          |
| Go                | `word_frequency.go`          |
| JavaScript        | `word_frequency.js`          |
| C#                | `WordFrequency.cs`           |
| Java              | `WordFrequency.java`         |
| Ruby              | `word_frequency.rb`          |
| Swift             | `word_frequency.swift`       |

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python word_frequency.py` |
| Go       | `go run word_frequency.go` |
| JavaScript | `node word_frequency.js` |
| C#       | `dotnet run` (or `csc WordFrequency.cs`) |
| Java     | `javac WordFrequency.java && java WordFrequency` |
| Ruby     | `ruby word_frequency.rb` |
| Swift    | `swift word_frequency.swift` |

## 📊 Example Session
=== Word Frequency Finder ===

Enter text manually

Load from file

Set number of top words (current: 10)

Toggle stop words (currently: on)

Exit
Choose: 1

Enter your text (end with Ctrl+D or empty line):
The quick brown fox jumps over the lazy dog. The dog barked.
[empty line]

Top 10 words:
the: 3 (27.3%)
dog: 2 (18.2%)
quick: 1 (9.1%)
brown: 1 (9.1%)
fox: 1 (9.1%)
jumps: 1 (9.1%)
over: 1 (9.1%)
lazy: 1 (9.1%)
barked: 1 (9.1%)

text

## 📁 File Format
Any plain text file (UTF-8) – words are split on whitespace and punctuation.

## 🔧 Technical Details
- **Stop words** – built-in lists for English (`en`) and Russian (`ru`); toggle on/off.
- **Word splitting** – uses regular expressions to extract alphabetic characters (Unicode-aware).
- **Performance** – O(n) time, O(m) memory where n = number of words, m = unique words.

## 🤝 Contributing
Add support for more languages, n-grams, or sentiment analysis – PRs welcome!

## 📜 License
MIT – use freely.
