# Calculate Reverse Polish notation
class RPNCalculator

  def initialize
    @stack = []
    @value = nil
  end

  def push(num)
    @stack.push(num)
  end

  def plus
    raise "calculator is empty" if @stack.length < 2
    nums = @stack.pop(2)
    @stack.push nums[0] + nums[1]
  end

  def minus
    raise "calculator is empty" if @stack.length < 2
    nums = @stack.pop(2)
    @stack.push nums[1] - nums[0]
  end

  def divide
    raise "calculator is empty" if @stack.length < 2
    nums = @stack.pop(2)
    @stack.push nums[1].to_f / nums[0]
  end

  def times
    raise "calculator is empty" if @stack.length < 2
    nums = @stack.pop(2)
    @stack.push nums[1].to_f * nums[0]
  end

  def value
    @stack.last
  end

  def tokens(str)
    tokens = str.split
    tokens.map! { |el| el =~ /^\d+$/ ? el.to_i : el.to_sym }
  end

  def evaluate(str)
    tokens = tokens(str)
    @stack = []
    tokens.map do |el|
      if el.is_a? Integer
        @stack.push el
      else
        case el
          when :+
            plus
          when :-
            minus
          when :*
            times
          else
            divide
        end
      end
    end
    value
  end

end
