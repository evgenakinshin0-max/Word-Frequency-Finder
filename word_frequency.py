# word_frequency.py
import re
import sys
from collections import Counter
from typing import List, Tuple, Optional

class WordFrequency:
    def __init__(self):
        self.stop_words_en = {'a', 'an', 'the', 'and', 'or', 'but', 'for', 'nor', 'on', 'at', 'to', 'by', 'in', 'with',
                              'without', 'of', 'for', 'per', 'via', 'plus', 'minus', 'up', 'down', 'off', 'over', 'under'}
        self.stop_words_ru = {'и', 'в', 'во', 'не', 'что', 'он', 'на', 'я', 'с', 'со', 'как', 'а', 'то', 'все', 'она',
                              'так', 'его', 'но', 'да', 'ты', 'к', 'у', 'же', 'вы', 'за', 'бы', 'по', 'только', 'ее',
                              'мне', 'было', 'вот', 'от', 'меня', 'еще', 'нет', 'о', 'из', 'ему', 'теперь', 'когда',
                              'даже', 'ну', 'вдруг', 'ли', 'если', 'уже', 'или', 'ни', 'быть', 'был', 'него', 'до',
                              'вас', 'нибудь', 'опять', 'уж', 'вам', 'ведь', 'там', 'потом', 'себя', 'ничего', 'ей',
                              'может', 'они', 'тут', 'где', 'есть', 'надо', 'ней', 'для', 'мы', 'тебя', 'их', 'чем',
                              'была', 'сам', 'чтоб', 'без', 'будто', 'чего', 'раз', 'тоже', 'себе', 'под', 'будет',
                              'ж', 'тогда', 'кто', 'этот', 'того', 'потому', 'этого', 'какой', 'совсем', 'ним', 'здесь',
                              'этом', 'один', 'почти', 'мой', 'тем', 'чтобы', 'нее', 'сейчас', 'были', 'куда', 'зачем',
                              'всех', 'можно', 'при', 'наконец', 'сегодня', 'любой', 'два', 'об', 'другой', 'хоть',
                              'после', 'над', 'больше', 'тот', 'через', 'эти', 'нас', 'про', 'всего', 'них', 'какая',
                              'много', 'разве', 'три', 'эту', 'моя', 'впрочем', 'хорошо', 'свою', 'этой', 'перед',
                              'иногда', 'лучше', 'чуть', 'том', 'нельзя', 'такой', 'более', 'всё', 'конечно', 'всю',
                              'между', 'ваше', 'начал', 'свое', 'свои', 'ваши', 'твою', 'тобой', 'тобою', 'твоя',
                              'твои', 'твое', 'вами', 'нами', 'вас', 'нас', 'меня', 'тебе', 'тобой'}
        self.use_stop_words = True
        self.top_n = 10
        self.language = 'en'  # 'en' or 'ru'

    def set_top_n(self, n: int):
        self.top_n = n

    def toggle_stop_words(self):
        self.use_stop_words = not self.use_stop_words

    def set_language(self, lang: str):
        self.language = lang

    def _get_stop_words(self) -> set:
        if self.language == 'ru':
            return self.stop_words_ru
        return self.stop_words_en

    def process_text(self, text: str) -> Tuple[List[Tuple[str, int]], int, float]:
        # Normalize: lowercase and extract words (Unicode letters only)
        words = re.findall(r'\b\w+\b', text.lower(), flags=re.UNICODE)
        total_words = len(words)
        if self.use_stop_words:
            stop = self._get_stop_words()
            words = [w for w in words if w not in stop]
        counter = Counter(words)
        most_common = counter.most_common(self.top_n)
        return most_common, total_words, counter

    def display(self, most_common: List[Tuple[str, int]], total_words: int, counter):
        if not most_common:
            print("No words found after filtering.")
            return
        print(f"\nTop {len(most_common)} words (total words: {total_words}, unique: {len(counter)}):")
        for word, count in most_common:
            pct = (count / total_words) * 100 if total_words else 0
            print(f"  {word}: {count} ({pct:.1f}%)")

def main():
    analyzer = WordFrequency()
    print("=== Word Frequency Finder ===")
    while True:
        print("\n1. Enter text manually")
        print("2. Load from file")
        print(f"3. Set number of top words (current: {analyzer.top_n})")
        print(f"4. Toggle stop words (currently: {'on' if analyzer.use_stop_words else 'off'})")
        print(f"5. Set language (current: {analyzer.language})")
        print("6. Exit")
        choice = input("Choose: ").strip()
        if choice == '1':
            print("Enter your text (end with empty line):")
            lines = []
            while True:
                line = input()
                if line == '':
                    break
                lines.append(line)
            text = '\n'.join(lines)
            if text:
                most_common, total, counter = analyzer.process_text(text)
                analyzer.display(most_common, total, counter)
        elif choice == '2':
            fname = input("Enter file path: ").strip()
            try:
                with open(fname, 'r', encoding='utf-8') as f:
                    text = f.read()
                most_common, total, counter = analyzer.process_text(text)
                analyzer.display(most_common, total, counter)
            except FileNotFoundError:
                print("File not found.")
            except Exception as e:
                print(f"Error: {e}")
        elif choice == '3':
            try:
                n = int(input("Enter number of top words: "))
                if n <= 0:
                    print("Must be positive.")
                else:
                    analyzer.set_top_n(n)
            except ValueError:
                print("Invalid number.")
        elif choice == '4':
            analyzer.toggle_stop_words()
            print("Stop words toggled.")
        elif choice == '5':
            lang = input("Enter language (en/ru): ").strip().lower()
            if lang in ('en', 'ru'):
                analyzer.set_language(lang)
                print(f"Language set to {lang}.")
            else:
                print("Invalid language.")
        elif choice == '6':
            print("Goodbye!")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
