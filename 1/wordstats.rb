def word_stats(text)
    words = text.downcase.scan(/\w+/)
    words_count = words.size
    longest_word = words.max_by(&:length)
    unique_words = words.uniq.size
    puts "#{words_count} words, longest: #{longest_word}, unique: #{unique_words}"
end

puts "Enter your text:"
input_text = gets.chomp
word_stats(input_text)
