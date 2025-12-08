class FactorialCalculator
  def factorial(n)
    raise ArgumentError, "Число не може бути від'ємним" if n < 0
    return 1 if n == 0 || n == 1
    n * factorial(n - 1)
  end
end

calc = FactorialCalculator.new

print "Введіть число: "
number = gets.to_i

begin
  result = calc.factorial(number)
  puts "Факторіал числа #{number} дорівнює #{result}"
rescue ArgumentError => e
  puts "Помилка: #{e.message}"
end