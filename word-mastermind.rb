# Word class responsible for checking legality of words
class Word
  # Use freeze as constants are mutable and freezing makes these truely constant, older versions allow constants to be changed so using freeze stops this
	WORD_LENGTH = 5.freeze
	START_LETTER = "a".freeze
	END_LETTER = "z".freeze

  # Class has no constructor as there are no variables to initialise or be passed in. Ruby allows you to not have an initialize

  # Function accepts a string input and outputs (returns) a true boolean if the string is 5 characters long, all letters and has no duplicate letters
  # Use question marks at the end of boolean functions, as this is a convention in ruby
	def legal?(word)
		self.is_length(word) && self.letters?(word) && self.duplicates?(word) # Will return true or false if given word is legal/not legal
	end

	# Function accepts a string
	# Iterates through each letter of word and will return false if a letter is not within range of a-z
	# Will return true if all letters are in the range a-z
	def letters?(word)
		# Split word and check if each letter is within the range a-z
		word.split('').each do |letter| # Use each loop as it is slightly better in performance, 'letter' iterator is encapsulated in a way that it cannot be accessed beyond each loop
			return false unless(START_LETTER..END_LETTER).include? letter
		end
		true # All characters in word are letters from a-z
	end
  
  # Function accepts a string as required input
  # Outputs a boolean, true if string is same length as WORD_LENGTH, false if not the same length
  # Boolean functions can also use the "is_" prefix instead of a question mark
	def is_length(word)
		word.length == WORD_LENGTH
	end
  
  # Function accepts a string as required input
  # Outputs a boolean, true if string's letters only occur once or zero times, false if occurs more than once in string
  # Method incorporates .all enumerable which in this case goes through each letter a-z and returns a boolean based off pattern given
	def duplicates?(word)
		# Go through the range a-z counting if each letter is only in the word string 0 or 1 times
		(START_LETTER..END_LETTER).all?  { |letter| word.count(letter) <= 1 } # will automatically return true or false
	end
end # End of Word class

# GameEngine class responsible for managing gameplay
class GameEngine
	LEGAL_WORDS = [] # Declare constant array of legal words as arrays can be constants in Ruby
  MAX_GUESS = 10.freeze

  # Function is a constructor, responsible for initialising variables when GameEngine object is created
  # Accepts a string file location as input
  # Outputs instance of created class
  def initialize(file)
    @@word = Word.new # @@ is a class variable
		self.read_word_file(file) # Read in word list file
		@guess_count = 0 # @ is an instance variable, is only available for current instance of GameEngine object
	end

  # Function accepts no input
  # Returns/outputs nil
  # Is responsible for controlling the game functionality.
  # Uses a do loop, which will run until exit or break statement is used, which will then end the game - this happens once a user enters a / to indicate they wish to stop playing
  def game_play
    self.new_round # Start new round
    loop do
      puts "Your Guess:"
      @input = gets.chomp # Gets user input by making a prompt and capturing the input, chomp method removes the new line which would otherwise be stored in the input string
      if @input != "/"
        if @@word.legal?(@input)
          if self.check_guess
            puts "Correct! You got the answer in #{@guess_count} guesses!" # Use string interpolation instead of concatenating to include guess count

            self.new_round
            puts @current_word
          end
          puts "You have #{MAX_GUESS - @guess_count} guesses remaining.\n?????" # Calculations can be made in string interpolation too
        else
          puts "That guess doesn't count! Your guess can only be 5 characters in length, contain no duplicate letters and only contain letters." # Guess isn't a legal word
        end
        self.check_lost # Check if player has exhausted amount of guesses
      else
        exit
      end
		end
	end

	# Function accepts a file location and reads each line of file, checking if word is "legal"
	# Returns nil, but puts legal words into array of legal words
	# Foreach loop through file so that lines are not loaded into memory at same time
		# Faster method than using read or readlines
	def read_word_file(file)
		File.foreach(file) do |line|
			if(@@word.legal?(line.chomp)) # Check if current line/word is legal
				LEGAL_WORDS << line.chomp # Add line/word to array of legal words
			end
    end
    LEGAL_WORDS.freeze # Freeze LEGAL_WORDS to make it immutable
	end

	# Function has no input, but outputs a random string from legal words array by using the Array sample method which returns a random element
	def random_word
		LEGAL_WORDS.sample # Gets random element from array
	end

  # Function accepts no input
  # Outputs a true value if the user input matches the chosen word
  # OR
  # Outputs/Returns nil value if not exact match, but displays out guess feedback
  # Ruby allows functions to return different types, e.g. a boolean, string, etc. in one function
  # This function will check if each letter of input has the same position as the value of i, if so, the letter is in the correct position.
  # Otherwise if checking the index of the letter in the chosen word returns nil, the letter is not in the word and it therefore must be somewhere else in the word.
	def check_guess
    @guess_count += 1 # Increment guess count
    @guess_feedback = ""
    return true if @input == @current_word # Return true value if input is same as chosen word - correctly guessed word
    i = 0
    @input.split('').each do |letter| # Split user input and check if each letter is in exact position as chosen word, or if it is somewhere or not in the word at all
      # Use << to append to string as this is faster and doesn't create new string objects, as opposed to concatenation using a +
      # Below line uses nested ternary operators, where the condition is first evaluated and then if true, the first statement is executed, if false, the second statement is executed
        # This allows the code to be more readable and shorter
      @current_word.index(letter) == i ? (@guess_feedback << "exact ") : (@current_word.index(letter).nil? ? (@guess_feedback << "miss ") : (@guess_feedback << "near "))
      i += 1
    end
    puts @guess_feedback
  end

  # Function accepts no input and outputs nil 
  # Checks if the guess count has reached the maximum guesses, if so it calls start new round function and displays that all guesses have been used
  def check_lost
    if @guess_count == MAX_GUESS
      puts "\tYou lost! You've used up all your guesses!"
      self.new_round
    end
  end
  
  # Function accepts no input and outputs/returns nil. 
  # Is responsible for starting a new round
  def new_round
    @guess_feedback = "" # Set guess feedback to be empty
    puts "\t\tNext Round!\n?????"
		@guess_count = 0 # Reset amount of guesses
		@current_word = self.random_word # Set a new random chosen/current word
	end
end # End of GameEngine class

WORD_LIST_FILE_NAME = 'word-list.txt'.freeze

# Function accepts no input and returns nil
# Prints message to player of how to play
def start_message
	puts "\t\t\t-- WORD MASTERMIND --"
  puts "\n\tYou will be given a 5 letter word and you must guess what the word is."
  puts "\n\tYou are allowed a maximum of 10 guesses per round."
	puts "\n\t\tEnter '/' key to stop playing."
end

@game_engine = GameEngine.new(WORD_LIST_FILE_NAME) # Create instance of GameEngine, giving it the word list file location/name

start_message # Display start message

@game_engine.game_play # Start game
