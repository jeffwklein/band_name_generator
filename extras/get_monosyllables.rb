require 'open-uri'

word_file = File.open("monosyllabic_1.txt","w")

(1..353).each do |page_number|
  web_page = open("http://www.yougorhymes.com/words-with-1-syllables/page/#{page_number}").read
  web_page.each_line do |line|
    break if (line[/END Rhyme Results/])
    next unless (line[/ has /])
    line = line.partition(/>.*has </)[1]
    line.slice!(0)
    line.slice!(/ has </)
    next if (line[/\w+\s+\w+/])
    line.downcase!
    word_file.puts line
  end
  puts "Page #{page_number} read"
end

