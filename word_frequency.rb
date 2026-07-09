# word_frequency.rb
require 'set'

class WordFrequency
  def initialize
    @stop_words_en = Set.new(%w[
      a an the and or but for nor on at to by in with without of per via plus minus up down off over under
    ])
    @stop_words_ru = Set.new(%w[
      и в во не что он на я с со как а то все она так его но да ты к у же вы за бы по только ее мне было
      вот от меня еще нет о из ему теперь когда даже ну вдруг ли если уже или ни быть был него до вас нибудь
      опять уж вам ведь там потом себя ничего ей может они тут где есть надо ней для мы тебя их чем была сам
      чтоб без будто чего раз тоже себе под будет ж тогда кто этот того потому этого какой совсем ним здесь
      этом один почти мой тем чтобы нее сейчас были куда зачем всех можно при наконец сегодня любой два об
      другой хоть после над больше тот через эти нас про всего них какая много разве три эту моя впрочем
      хорошо свою этой перед иногда лучше чуть том нельзя такой более всё конечно всю между ваше начал свое
      свои ваши твою тобой тобою твоя твои твое вами нами
    ])
    @use_stop_words = true
    @top_n = 10
    @language = 'en'
  end

  attr_accessor :top_n, :use_stop_words, :language

  def stop_words
    @language == 'ru' ? @stop_words_ru : @stop_words_en
  end

  def process_text(text)
    words = text.downcase.scan(/\b\w+\b/)
    total = words.size
    filtered = @use_stop_words ? words.reject { |w| stop_words.include?(w) } : words
    freq = Hash.new(0)
    filtered.each { |w| freq[w] += 1 }
    sorted = freq.sort_by { |w, c| [-c, w] }
    top = sorted.first(@top_n).map { |w, c| { word: w, count: c } }
    { top: top, total: total, unique: freq.size }
  end

  def display(result)
    if result[:top].empty?
      puts "No words found after filtering."
      return
    end
    puts "\nTop #{result[:top].size} words (total: #{result[:total]}, unique: #{result[:unique]}):"
    result[:top].each do |item|
      pct = item[:count].to_f / result[:total] * 100
      puts "  #{item[:word]}: #{item[:count]} (#{'%.1f' % pct}%)"
    end
  end
end

def main
  analyzer = WordFrequency.new
  puts "=== Word Frequency Finder ==="
  loop do
    puts "\n1. Enter text manually"
    puts "2. Load from file"
    puts "3. Set number of top words (current: #{analyzer.top_n})"
    puts "4. Toggle stop words (currently: #{analyzer.use_stop_words ? 'on' : 'off'})"
    puts "5. Set language (current: #{analyzer.language})"
    puts "6. Exit"
    print "Choose: "
    choice = gets.chomp.strip
    case choice
    when '1'
      puts "Enter your text (end with empty line):"
      lines = []
      loop do
        line = gets.chomp
        break if line.empty?
        lines << line
      end
      text = lines.join("\n")
      unless text.empty?
        result = analyzer.process_text(text)
        analyzer.display(result)
      end
    when '2'
      print "Enter file path: "
      fname = gets.chomp.strip
      unless File.exist?(fname)
        puts "File not found."
        next
      end
      content = File.read(fname)
      result = analyzer.process_text(content)
      analyzer.display(result)
    when '3'
      print "Enter number of top words: "
      n = gets.chomp.to_i
      if n <= 0
        puts "Must be positive."
      else
        analyzer.top_n = n
      end
    when '4'
      analyzer.use_stop_words = !analyzer.use_stop_words
      puts "Stop words toggled."
    when '5'
      print "Enter language (en/ru): "
      lang = gets.chomp.strip.downcase
      if ['en', 'ru'].include?(lang)
        analyzer.language = lang
        puts "Language set to #{lang}."
      else
        puts "Invalid language."
      end
    when '6'
      puts "Goodbye!"
      break
    else
      puts "Invalid choice."
    end
  end
end

main if __FILE__ == $0
