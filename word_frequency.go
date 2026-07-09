// word_frequency.go
package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"sort"
	"strings"
)

type WordFrequency struct {
	stopWordsEn   map[string]bool
	stopWordsRu   map[string]bool
	useStopWords  bool
	topN          int
	language      string
}

func NewWordFrequency() *WordFrequency {
	en := map[string]bool{
		"a": true, "an": true, "the": true, "and": true, "or": true, "but": true,
		"for": true, "nor": true, "on": true, "at": true, "to": true, "by": true,
		"in": true, "with": true, "without": true, "of": true, "per": true,
		"via": true, "plus": true, "minus": true, "up": true, "down": true,
		"off": true, "over": true, "under": true,
	}
	ru := map[string]bool{
		"и": true, "в": true, "во": true, "не": true, "что": true, "он": true,
		"на": true, "я": true, "с": true, "со": true, "как": true, "а": true,
		"то": true, "все": true, "она": true, "так": true, "его": true,
		"но": true, "да": true, "ты": true, "к": true, "у": true, "же": true,
		"вы": true, "за": true, "бы": true, "по": true, "только": true,
		"ее": true, "мне": true, "было": true, "вот": true, "от": true,
		"меня": true, "еще": true, "нет": true, "о": true, "из": true,
		"ему": true, "теперь": true, "когда": true, "даже": true, "ну": true,
		"вдруг": true, "ли": true, "если": true, "уже": true, "или": true,
		"ни": true, "быть": true, "был": true, "него": true, "до": true,
		"вас": true, "нибудь": true, "опять": true, "уж": true, "вам": true,
		"ведь": true, "там": true, "потом": true, "себя": true, "ничего": true,
		"ей": true, "может": true, "они": true, "тут": true, "где": true,
		"есть": true, "надо": true, "ней": true, "для": true, "мы": true,
		"тебя": true, "их": true, "чем": true, "была": true, "сам": true,
		"чтоб": true, "без": true, "будто": true, "чего": true, "раз": true,
		"тоже": true, "себе": true, "под": true, "будет": true, "ж": true,
		"тогда": true, "кто": true, "этот": true, "того": true, "потому": true,
		"этого": true, "какой": true, "совсем": true, "ним": true, "здесь": true,
		"этом": true, "один": true, "почти": true, "мой": true, "тем": true,
		"чтобы": true, "нее": true, "сейчас": true, "были": true, "куда": true,
		"зачем": true, "всех": true, "можно": true, "при": true, "наконец": true,
		"сегодня": true, "любой": true, "два": true, "об": true, "другой": true,
		"хоть": true, "после": true, "над": true, "больше": true, "тот": true,
		"через": true, "эти": true, "нас": true, "про": true, "всего": true,
		"них": true, "какая": true, "много": true, "разве": true, "три": true,
		"эту": true, "моя": true, "впрочем": true, "хорошо": true, "свою": true,
		"этой": true, "перед": true, "иногда": true, "лучше": true, "чуть": true,
		"том": true, "нельзя": true, "такой": true, "более": true, "всё": true,
		"конечно": true, "всю": true, "между": true, "ваше": true, "начал": true,
		"свое": true, "свои": true, "ваши": true, "твою": true, "тобой": true,
		"тобою": true, "твоя": true, "твои": true, "твое": true, "вами": true,
		"нами": true,
	}
	return &WordFrequency{
		stopWordsEn:  en,
		stopWordsRu:  ru,
		useStopWords: true,
		topN:         10,
		language:     "en",
	}
}

func (wf *WordFrequency) getStopWords() map[string]bool {
	if wf.language == "ru" {
		return wf.stopWordsRu
	}
	return wf.stopWordsEn
}

func (wf *WordFrequency) processText(text string) ([]struct{ Word string; Count int }, int, int) {
	// Lowercase and extract words (Unicode letters)
	re := regexp.MustCompile(`\b\w+\b`)
	words := re.FindAllString(strings.ToLower(text), -1)
	total := len(words)
	stop := wf.getStopWords()
	filtered := []string{}
	for _, w := range words {
		if !wf.useStopWords || !stop[w] {
			filtered = append(filtered, w)
		}
	}
	freq := make(map[string]int)
	for _, w := range filtered {
		freq[w]++
	}
	type pair struct {
		Word  string
		Count int
	}
	pairs := []pair{}
	for w, c := range freq {
		pairs = append(pairs, pair{w, c})
	}
	sort.Slice(pairs, func(i, j int) bool {
		if pairs[i].Count == pairs[j].Count {
			return pairs[i].Word < pairs[j].Word
		}
		return pairs[i].Count > pairs[j].Count
	})
	result := []struct{ Word string; Count int }{}
	limit := wf.topN
	if limit > len(pairs) {
		limit = len(pairs)
	}
	for i := 0; i < limit; i++ {
		result = append(result, struct{ Word string; Count int }{pairs[i].Word, pairs[i].Count})
	}
	return result, total, len(freq)
}

func (wf *WordFrequency) display(result []struct{ Word string; Count int }, total, unique int) {
	if len(result) == 0 {
		fmt.Println("No words found after filtering.")
		return
	}
	fmt.Printf("\nTop %d words (total: %d, unique: %d):\n", len(result), total, unique)
	for _, item := range result {
		pct := float64(item.Count) / float64(total) * 100
		fmt.Printf("  %s: %d (%.1f%%)\n", item.Word, item.Count, pct)
	}
}

func main() {
	analyzer := NewWordFrequency()
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== Word Frequency Finder ===")
	for {
		fmt.Println("\n1. Enter text manually")
		fmt.Println("2. Load from file")
		fmt.Printf("3. Set number of top words (current: %d)\n", analyzer.topN)
		fmt.Printf("4. Toggle stop words (currently: %s)\n", map[bool]string{true: "on", false: "off"}[analyzer.useStopWords])
		fmt.Printf("5. Set language (current: %s)\n", analyzer.language)
		fmt.Println("6. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			fmt.Println("Enter your text (end with empty line):")
			var lines []string
			for {
				scanner.Scan()
				line := scanner.Text()
				if line == "" {
					break
				}
				lines = append(lines, line)
			}
			text := strings.Join(lines, "\n")
			if text != "" {
				result, total, unique := analyzer.processText(text)
				analyzer.display(result, total, unique)
			}
		case "2":
			fmt.Print("Enter file path: ")
			scanner.Scan()
			fname := strings.TrimSpace(scanner.Text())
			data, err := ioutil.ReadFile(fname)
			if err != nil {
				fmt.Println("File not found.")
				break
			}
			text := string(data)
			result, total, unique := analyzer.processText(text)
			analyzer.display(result, total, unique)
		case "3":
			fmt.Print("Enter number of top words: ")
			scanner.Scan()
			var n int
			fmt.Sscan(scanner.Text(), &n)
			if n <= 0 {
				fmt.Println("Must be positive.")
			} else {
				analyzer.topN = n
			}
		case "4":
			analyzer.useStopWords = !analyzer.useStopWords
			fmt.Println("Stop words toggled.")
		case "5":
			fmt.Print("Enter language (en/ru): ")
			scanner.Scan()
			lang := strings.ToLower(strings.TrimSpace(scanner.Text()))
			if lang == "en" || lang == "ru" {
				analyzer.language = lang
				fmt.Printf("Language set to %s.\n", lang)
			} else {
				fmt.Println("Invalid language.")
			}
		case "6":
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}
