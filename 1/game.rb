def guess_the_number
  number = rand(1..100)
  attempts = 0

  puts "Guess the number from 1 to 100."

  loop do
    puts "Enter a number: "
    begin
      guess = Integer(gets.chomp)
    rescue ArgumentError
      puts "You have to enter an integer."
      next
    end
    attempts += 1

    if guess < number
      puts "Higher"
    elsif guess > number
      puts "Lower"
    else
      puts "Congrats! You guessed the number #{number} in #{attempts} attempts."
      break
    end
  end
end

guess_the_number
