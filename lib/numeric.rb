require 'math_util'

class Numeric
  def degrees
    MathUtil.tau * self / 360
  end
end
