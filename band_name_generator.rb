# band_name_generator.rb
# Author: Jeffrey Klein
# jeffreykle.in
#
# Source of word lists: http://www.ashley-bovan.co.uk/words/feet.html
#
# Command-line app that generates a band name based on a user prompt.
# Each argument specifies properties for a particular word in a resulting
# randomly generated band name.
#
# In this representation, a 0 denotes an unaccented syllable while a 1
# denotes an accented one.
#
# Refer to the following table as a guide:
#   (Argument) | (Inflection Type) | (Example Word)
#   1          | monosyllabic      | crane
#   01         | iamb              | guitar
#   10         | trochee           | lightning
#   001        | anapest           | japanese
#   010        | amphibrach        | performance
#   100        | dactyl            | scientist
#
# These additional options can help the user specify or broaden
# his or her request further: 
# - A word provided as an argument will be added verbatim.
# - Add a string of letters to the beginning or end of the syllable
#   code to force the result to begin or with a string.
#   e.g. fa010c -> fantastic
# - Add the flag -a* for alliteration, where * is the start letter.
#   Leaving a star will pick a letter at random.
#   e.g. 10 10 -ap -> purple panda
# - The flag -p will return all permutations of the results.
#   e.g. flightless 10 -a -> flightless parrot, parrot flightless
# - A single * will return any random word from the lists
#   e.g. * -> peanut
# - Ending an argument with #n will repeat the argument n times
#   e.g. fr10#3 -> freedom fringes fronting
# - A flag with any number -[n] will repeat the query n times.
#   e.g. 10 -3 -> sofa, fearful, yonder
#
# Some example inputs and outputs:
#
#   Input:
#   > 10 10 100
#   Output:
#   > Frankly Dollar Parasail
#
#   Input:
#   > The 10 010
#   Output:
#   > The Pirate Collective
#
#   Input:
#   > 1 01 -a*
#   Output:
#   > Cat Charade
#
#   Input:
#   > r10 el1 -p
#   Output:
#   > Racket Elf
#   > Elf Racket
#
#   Input:
#   > r1#2 un010
#   Output:
#   > Rage Rat Unlawful
#
#   Input:
#   > f10y#2 -2
#   Output:
#   > Fancy Frankly
#   > Folly Fairy
#

require "./parser"

puts "\nBand Name Generator v0.0"
puts "Jeffrey Klein, 2014"
puts "\nEnter -help for formatting info"
puts "Enter -exit to leave"
puts "\n"

# processes user arguments and returns a band name
def process arg_array
  # account for *#n "repeat n times"
  arg_array = Parser.add_repeated_args(arg_array)
  Parser.interpret_args(arg_array)
end

def print_help
  puts "TODO: Create help dialog"
end

help_counter = 0
# Begin main loop
while true
  print "> "
  input = gets.chomp
  if input == "-help"
    print_help
    next
  end
  if input == "-exit" || input == "exit" # temp latter option for quick test purposes
    puts "Exiting"
    exit
  end
  unless (input[/(\w+|\*)/])
    help_counter += 1
    if (help_counter == 4)
      puts "You seem to be having trouble there. Type -help for some guidance."
      help_counter = 0
    end
    next
  end
  input_args = input.scan(/\S+/)
  process(input_args)
end




