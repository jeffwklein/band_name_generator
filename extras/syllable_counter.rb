def count(word)
  word.downcase!
  return 1 if word.length <= 3
  word.sub!(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '')
  word.sub!(/^y/, '')
  word.scan(/[aeiouy]{1,2}/).size
end


filename = ARGV.first
new_text = File.open("new_#{filename}","w")
File.readlines(filename).each do |word|
  new_text.puts(word) if count(word) == 1
end
