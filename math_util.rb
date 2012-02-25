module MathUtil
  def tau
    2 * Math::PI
  end
  
  def half_tau
    Math::PI
  end
  
  def quarter_tau
    Math::PI / 2.0
  end
  
  def inverse_half_tau
    1 / Math::PI
  end
  
  def inverse_tau
    1 / tau
  end
  
  def wrap_tau(theta)
    theta += theta + PI
    theta -= (theta / tau).floor * tau
    theta -= tau
  end
  
  def safe_acos(x)
    if x <= -1
      PI
    elsif x >= 1
      0
    else
      Math::acos(x)
    end
  end
  
  def sin_cos(theta)
    [Math::sin(theta).round(6), Math::cos(theta).round(6)]
  end
end
