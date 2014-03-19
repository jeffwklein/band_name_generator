filename = ARGV.first
text = File.open(filename)

word_list = Hash.new("zzz")
count = 0
text.each do |word|
  word_list[count] = word
  count += 1
end

alphabetized_list = word_list.values.sort

new_text = File.open("new_#{filename}","w")
alphabetized_list.each do |word|
  new_text.puts(word)
end

