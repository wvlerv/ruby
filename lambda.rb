sum3 = ->(a, b, c) { a + b + c }

def curry3(proc_or_lambda)
  raise ArgumentError, "Must accept exactly 3 arguments" unless proc_or_lambda.arity == 3

   accumulator = ->(collected_args) {
    ->(*new_args) do
      all_args = collected_args + new_args

      if all_args.size > 3
        raise ArgumentError, "Too many arguments (expected 3)"
      elsif all_args.size == 3
        proc_or_lambda.call(*all_args)
      else
        accumulator.call(all_args)
      end
    end
  }

  accumulator.call([])  
end

cur = curry3(sum3)

p cur.call(1).call(2).call(3)       # => 6
p cur.call(1, 2).call(3)            # => 6
p cur.call(1).call(2, 3)            # => 6
p cur.call()                        # => #<Proc: ...>  (чекає 3 аргументи)
p cur.call(1, 2, 3)                 # => 6
# cur.call(1, 2, 3, 4)              # => ArgumentError

# Інший приклад
f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)
p cF.call('A').call('B', 'C')        # => "A-B-C"