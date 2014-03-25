module Parser
  # REGEXES
  Validate_repeat_arg = /\b\w+#\d+\b/
  Extract_repeat_arg_count = /#\d+\b/
  Is_single_word_argument = /^[A-Za-z]+$/
  Has_valid_syllable_pattern = /^[a-zA-Z]*(1|01|10|001|010|100)[a-zA-Z]*$/
  Extract_syllable_pattern = /0*10*/
  Extract_prefix = /\b([a-z]|[A-Z])*\B/
  Extract_suffix = /\B([a-z]|[A-Z])*\b/
  Is_valid_flag = /^\-(a([a-zA-Z\*])|p|\d+)$/
  ###

  $list_length = {
    "1" => 2396,
    "01" => 712,
    "10" => 2622,
    "001" => 204,
    "010" => 903,
    "100" => 757,
    total: 7594
  }
  $list_filename = {
    "1" => "word_lists/monosyllabic_1.txt",
    "01" => "word_lists/iamb_01.txt",
    "10" => "word_lists/trochee_10.txt",
    "001" => "word_lists/anapest_001.txt",
    "010" => "word_lists/amphribrach_010.txt",
    "100" => "word_lists/dactyl_100.txt",
    all: "word_lists/dictionary.txt"
  }


  def self.add_repeated_args arg_array
    result = []
    arg_array.each do |arg|
      if (arg[Validate_repeat_arg])
        copies = arg.slice!(Extract_repeat_arg_count).tr("#","").to_i
        repeated_args = Array.new(copies, arg)
        (result << repeated_args).flatten!
      else
        result << arg
      end
    end
    return result
  end

  def self.find_random_words (info_array)
    #puts info_array.inspect
    result_vector = []
    info_array.each do |info|
      # set default values
      info = {
        single_word: false,
        wildcard: false,
        prefix: nil,
        syllable_pattern: nil,
        suffix: nil,
        alliteration: nil,
        permute: false
      }.merge(info)

      if (info[:alliteration] && info[:prefix])
        puts "Error: cannot have prefixes when alliteration flag is present"
        return
      elsif (info[:alliteration])
        info[:prefix] = info[:alliteration]
      end

      lists = $list_length.keys
      if (info[:single_word])
        result_vector << info[:prefix]
      else
        search_file = $list_filename[info[:syllable_pattern]]
        search_file = $list_filename[:all] if info[:wildcard]
        unless info[:prefix] || info[:suffix]
          result_vector << File.readlines(search_file).sample
        else
          matches = []
          match_regex = /\b#{info[:prefix]}\w*#{info[:suffix]}\b/
          File.readlines(search_file).each do |word|
            matches << word if (word[match_regex])
          end
          if (matches.size == 0)
            puts "No matches found for pattern #{info[:prefix]}#{info[:syllable_pattern]}#{info[:suffix]}"
           return
          else
            result_vector << matches[rand(matches.size)]
          end
        end
      end
    end
    result_vector.each { |word| word.capitalize! }
    result_vector.each { |word| word.chomp! }
    if (info_array[0][:permute])
      result_vector.permutation.to_a.each do |perm|
        puts perm.join(" ")
      end
    else
      puts result_vector.join(" ")
    end
  end


  def self.invalid_arg_error arg
    puts "Invalid syntax: argument \"#{arg}\""
    true
  end


  def self.interpret_args arg_array
    #split into parts
    #determine parameters and scope of search
    overall_info = {}
    repeat = 1
    arg_array.each do |arg|
      if (arg[Is_valid_flag])
        #puts "flag #{arg} is valid"
        if (arg[1] == "a")
          if (arg[2] == "*")
            overall_info[:alliteration] = ("a".."z").to_a.sample
          else
            overall_info[:alliteration] = arg[2]
          end
        elsif (arg[1] == "p")
          overall_info[:permute] = true
          #puts "Detected #{arg} as perm flag"
        elsif (arg[1][/\d/])
          repeat = arg[/\d+/].to_i
        else
          puts "Invalid flag: \"#{arg}\""
          return
        end
      end
    end
    arg_array.delete_if { |arg| arg[0] == "-" }
    info_array = []
    arg_array.each do |arg|
      word_info = {}
      if (arg.count("*") == 1)
        word_info[:prefix] = arg[0, arg.index("*")]
        word_info[:suffix] = arg[arg.index("*")+1..-1]
        unless word_info[:prefix] == ""
          return invalid_arg_error(arg) unless word_info[:prefix][/\b([a-z]|[A-Z])+\b/]
        else
          word_info[:prefix] = nil
        end
        unless word_info[:suffix] == ""
          return invalid_arg_error(arg) unless word_info[:suffix][/\b([a-z]|[A-Z])+\b/]
        else
          word_info[:suffix] = nil
        end
        word_info[:wildcard] = true
      elsif (arg[Has_valid_syllable_pattern])
        word_info[:syllable_pattern] = arg[Extract_syllable_pattern]
        #puts "Detected #{arg} syllable pattern as #{word_info[:syllable_pattern]}"
      elsif (arg[Is_single_word_argument])
        word_info[:single_word] = true
        #puts "Detected #{arg} as single word"
        word_info[:prefix] = arg
      else
        invalid_arg_error arg
        return
      end
      word_info[:prefix] = arg[Extract_prefix] unless word_info[:single_word] || word_info[:wildcard]
      #puts "Detected #{arg} prefix as #{word_info[:prefix]}"
      word_info[:suffix] = arg[Extract_suffix] unless word_info[:single_word] || word_info[:wildcard]
      #puts "Detected #{arg} suffix as #{word_info[:suffix]}"
      word_info.merge!(overall_info)
      info_array << word_info
    end
    while repeat > 0
      find_random_words(info_array)
      repeat -= 1
    end
  end

end
