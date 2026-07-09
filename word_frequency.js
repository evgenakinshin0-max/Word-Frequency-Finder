// word_frequency.js
const readline = require('readline');
const fs = require('fs');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

class WordFrequency {
    constructor() {
        this.stopWordsEn = new Set([
            'a', 'an', 'the', 'and', 'or', 'but', 'for', 'nor', 'on', 'at',
            'to', 'by', 'in', 'with', 'without', 'of', 'per', 'via', 'plus',
            'minus', 'up', 'down', 'off', 'over', 'under'
        ]);
        this.stopWordsRu = new Set([
            'и', 'в', 'во', 'не', 'что', 'он', 'на', 'я', 'с', 'со', 'как',
            'а', 'то', 'все', 'она', 'так', 'его', 'но', 'да', 'ты', 'к',
            'у', 'же', 'вы', 'за', 'бы', 'по', 'только', 'ее', 'мне', 'было',
            'вот', 'от', 'меня', 'еще', 'нет', 'о', 'из', 'ему', 'теперь',
            'когда', 'даже', 'ну', 'вдруг', 'ли', 'если', 'уже', 'или', 'ни',
            'быть', 'был', 'него', 'до', 'вас', 'нибудь', 'опять', 'уж', 'вам',
            'ведь', 'там', 'потом', 'себя', 'ничего', 'ей', 'может', 'они',
            'тут', 'где', 'есть', 'надо', 'ней', 'для', 'мы', 'тебя', 'их',
            'чем', 'была', 'сам', 'чтоб', 'без', 'будто', 'чего', 'раз',
            'тоже', 'себе', 'под', 'будет', 'ж', 'тогда', 'кто', 'этот',
            'того', 'потому', 'этого', 'какой', 'совсем', 'ним', 'здесь',
            'этом', 'один', 'почти', 'мой', 'тем', 'чтобы', 'нее', 'сейчас',
            'были', 'куда', 'зачем', 'всех', 'можно', 'при', 'наконец',
            'сегодня', 'любой', 'два', 'об', 'другой', 'хоть', 'после',
            'над', 'больше', 'тот', 'через', 'эти', 'нас', 'про', 'всего',
            'них', 'какая', 'много', 'разве', 'три', 'эту', 'моя', 'впрочем',
            'хорошо', 'свою', 'этой', 'перед', 'иногда', 'лучше', 'чуть',
            'том', 'нельзя', 'такой', 'более', 'всё', 'конечно', 'всю',
            'между', 'ваше', 'начал', 'свое', 'свои', 'ваши', 'твою',
            'тобой', 'тобою', 'твоя', 'твои', 'твое', 'вами', 'нами'
        ]);
        this.useStopWords = true;
        this.topN = 10;
        this.language = 'en';
    }

    getStopWords() {
        return this.language === 'ru' ? this.stopWordsRu : this.stopWordsEn;
    }

    processText(text) {
        // Normalize and extract words
        const words = text.toLowerCase().match(/\b\w+\b/g) || [];
        const total = words.length;
        const stop = this.getStopWords();
        const filtered = this.useStopWords ?
            words.filter(w => !stop.has(w)) :
            words;
        const freq = {};
        for (const w of filtered) {
            freq[w] = (freq[w] || 0) + 1;
        }
        const sorted = Object.entries(freq).sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
        const top = sorted.slice(0, this.topN).map(([word, count]) => ({ word, count }));
        return { top, total, unique: sorted.length };
    }

    display({ top, total, unique }) {
        if (top.length === 0) {
            console.log("No words found after filtering.");
            return;
        }
        console.log(`\nTop ${top.length} words (total: ${total}, unique: ${unique}):`);
        for (const item of top) {
            const pct = (item.count / total * 100);
            console.log(`  ${item.word}: ${item.count} (${pct.toFixed(1)}%)`);
        }
    }
}

async function main() {
    const analyzer = new WordFrequency();
    console.log("=== Word Frequency Finder ===");
    while (true) {
        console.log("\n1. Enter text manually");
        console.log("2. Load from file");
        console.log(`3. Set number of top words (current: ${analyzer.topN})`);
        console.log(`4. Toggle stop words (currently: ${analyzer.useStopWords ? 'on' : 'off'})`);
        console.log(`5. Set language (current: ${analyzer.language})`);
        console.log("6. Exit");
        const choice = await ask("Choose: ");
        switch (choice.trim()) {
            case '1': {
                console.log("Enter your text (end with empty line):");
                const lines = [];
                while (true) {
                    const line = await ask("");
                    if (line === '') break;
                    lines.push(line);
                }
                const text = lines.join('\n');
                if (text) {
                    const result = analyzer.processText(text);
                    analyzer.display(result);
                }
                break;
            }
            case '2': {
                const fname = await ask("Enter file path: ");
                try {
                    const data = fs.readFileSync(fname, 'utf8');
                    const result = analyzer.processText(data);
                    analyzer.display(result);
                } catch (e) {
                    console.log("File not found or error.");
                }
                break;
            }
            case '3': {
                const n = parseInt(await ask("Enter number of top words: "));
                if (isNaN(n) || n <= 0) {
                    console.log("Must be a positive integer.");
                } else {
                    analyzer.topN = n;
                }
                break;
            }
            case '4':
                analyzer.useStopWords = !analyzer.useStopWords;
                console.log("Stop words toggled.");
                break;
            case '5': {
                const lang = await ask("Enter language (en/ru): ");
                if (lang === 'en' || lang === 'ru') {
                    analyzer.language = lang;
                    console.log(`Language set to ${lang}.`);
                } else {
                    console.log("Invalid language.");
                }
                break;
            }
            case '6':
                console.log("Goodbye!");
                rl.close();
                return;
            default:
                console.log("Invalid choice.");
        }
    }
}

main().catch(console.error);
