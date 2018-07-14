# balance paranthesis using stack


def is_balanced?(str)
  n = str.size
  return true if n == 0

  open_brackets = ["{", "[", "("]
  closed_brackets = ["}", "]", ")"]

  close_to_open = {

    "}" => "{",
    "]" => "[",
    ")" => "("
  }

  stack = []
  i = 0
  while(i < n)
    if open_brackets.include? str[i]
      stack.push(str[i])
    elsif closed_brackets.include? str[i]
        popped_bracket = nil
        popped_bracket = stack.pop
        return false if popped_bracket.nil? || popped_bracket != close_to_open[str[i]]
    end
    i += 1
  end

  return stack.empty?

end


puts is_balanced?("()[]{}") ? "True" : "false"
puts is_balanced?("([{}])") ? "True" : "false"
puts is_balanced?("([]{})") ? "True" : "false"
puts is_balanced?("([)]") ? "True" : "false"
puts is_balanced?("([]") ? "True" : "false"
puts is_balanced?("[])") ? "True" : "false"
puts is_balanced?("([})") ? "True" : "false"
