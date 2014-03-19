module Parser
  # REGEXES
  Validate_repeat_arg = /\b\w+#\d+\b/
  Extract_repeat_arg_count = /#\d+\b/
  Is_single_word_argument = /([a-z]|[A-Z])+\b/
  Has_valid_syllable_pattern = /([a-z]|[A-Z])*(1|01|10|001|010|100)([a-z]|[A-Z])*\b/
  Extract_syllable_pattern = /0*10*/
  Extract_prefix = /\b([a-z]|[A-Z])*\B/
  Extract_suffix = /\B([a-z]|[A-Z])*\b/
  Is_valid_flag = /\-(a([a-z]|[A-Z]|\*)|p|\d+)\b/
  Is_wildcard = /\b\*\b/
  ###

  $list_length = {
    mono: 7085,
    iamb: 5056,
    trochee: 36963,
    anapest: 204,
    amphribrach: 10832,
    dactyl: 10432,
    total: 70572
  }
  $list_filename = {
    mono: "word_lists/monosyllabic_1.txt",
    iamb: "word_lists/iamb_01.txt",
    trochee: "word_lists/trochee_10.txt",
    anapest: "word_lists/anapest_001.txt",
    amphribrach: "word_lists/amphribrach_010.txt",
    dactyl: "word_lists/dactyl_100.txt"
  }

  $code_to_name = {
    "1" => :mono,
    "01" => :iamb,
    "10" => :trochee,
    "001" => :anapest,
    "010" => :amphribrach,
    "100" => :dactyl
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

  def self.find_random_words (info_array, repeat = 1)
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
      elsif (info[:wildcard])
        random_int = rand($list_length[:total])
        sum = 0
        search_list = nil
        lists.each do |list|
          sum += $list_length[list]
          search_list = list
          break if random_int < sum
        end
        random_index = rand($list_length[search_list])
        result_vector << File.readlines($list_filename[search_list])[random_index]
      else
        filename = $list_filename[$code_to_name[info[:syllable_pattern]]]
        random_index = rand($list_length[$code_to_name[info[:syllable_pattern]]]) 
        unless info[:prefix] || info[:suffix]
          result_vector << File.readlines(filename)[random_index]
        else
          matches = []
          match_regex = /\b#{info[:prefix]}\w*#{info[:suffix]}\b/
          File.readlines(filename).each do |word|
            matches << word if (word[match_regex])
          end
          if (matches.size == 0)
            puts "No matches found for pattern #{info[:prefix]}#{info[:syllable_pattern]}#{info[:suffix]}"
           return
          else
            result_vector << matches[rand(matches.size)]
            #puts result_vector.inspect
          end
        end
      end
    end
    results_list = []
    result_vector.each { |word| word.capitalize! }
    if (info_array[0][:permute])
      result_vector.permutation.to_a.each do |perm|
        perm.each { |word| word.chomp! }
        puts perm.join(" ")
      end
    else
      result_vector.each { |word| word.chomp! }
      puts result_vector.join(" ")
    end
    repeat -= 1
    find_random_words(info_array, repeat) if repeat > 0
    results_list.flatten!
    return results_list
  end

  def self.interpret_args arg_array
    #split into parts
    #determine parameters and scope of search
    overall_info = {}
    repeat = 1
    arg_array.each do |arg|
      if (arg[Is_wildcard])
        puts "detected wildcard"
        overall_info[:wildcard] = true
      elsif (arg[Is_valid_flag])
        #puts "flag #{arg} is valid"
        if (arg[1] == "a")
          if (arg[2] == "*")
            overall_info[:alliteration] = File.readlines("word_lists/iamb_01.txt")[rand($list_length[:iamb])][0]
          else
            overall_info[:alliteration] = arg[2]
          end
          #puts "Detected #{arg} as alliteration flag"
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
    arg_array.delete_if { |arg| arg[0] == "-" || arg[0] == "*" }
    info_array = []
    arg_array.each do |arg|
      word_info = {}
      if (arg[Has_valid_syllable_pattern])
        word_info[:syllable_pattern] = arg[Extract_syllable_pattern]
        #puts "Detected #{arg} syllable pattern as #{word_info[:syllable_pattern]}"
      elsif (arg[Is_single_word_argument])
        word_info[:single_word] = true
        #puts "Detected #{arg} as single word"
        word_info[:prefix] = arg
      else
        puts "Invalid syntax: argument \"#{arg}\""
        return
      end
      word_info[:prefix] = arg[Extract_prefix] unless (word_info[:prefix] == arg)
      #puts "Detected #{arg} prefix as #{word_info[:prefix]}"
      word_info[:suffix] = arg[Extract_suffix] unless word_info[:single_word]
      #puts "Detected #{arg} suffix as #{word_info[:suffix]}"
      #puts word_info.inspect
      word_info.merge!(overall_info)
      info_array << word_info
    end
    band_names_list = find_random_words(info_array, repeat)
    band_names_list.each { |name| puts name.inspect }
  end

end
