class Vector
  attr_accessor :x, :y, :z
  
  class << self
    def zero
      @@zero ||= Vector.new(0, 0, 0)
    end
  end
  
  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end
  
  def to_s
    "Vector[#{@x}, #{@y}, #{@z}]"
  end
  
  def eql?(other)
    [@x, @y, @z] == [other.x, other.y, other.z]
  end
  
  def clear!
    @x = @y = @z = 0.0
  end
  
  def inverse
    self.class.new(-@x, -@y, -@z)
  end
  
  def +(vector)
    self.class.new(@x + vector.x, @y + vector.y, @z + vector.z)
  end
  
  def -(vector)
    self.class.new(@x - vector.x, @y - vector.y, @z - vector.z)
  end
  
  def *(scalar_or_vector)
    case scalar_or_vector.class
    when Numeric
      scalar_multiplication(scalar_or_vector)
    when Vector
      dot_product(scalar_or_vector)
    else
      raise "Operation not supported"
    end
  end
  
  def /(scalar)
    inverse_scalar = 1 / scalar.to_f
    self.class.new(@x * inverse_scalar, @y * inverse_scalar, @z * inverse_scalar)
  end
  
  def plus_assign(vector)
    @x += vector.x
    @y += vector.y
    @z += vector.z
    
    return self
  end
  
  def minus_assign(vector)
    @x -= vector.x
    @y -= vector.y
    @z -= vector.z
    
    return self
  end
  
  def multiply_assign(scalar)
    @x *= scalar.x
    @y *= scalar.y
    @z *= scalar.z
    
    return self
  end
  
  def cross_product(vector)
    self.class.new(@y * vector.z - @z * vector.y, @z * vector.x - @x * vector.z, @x * vector.y - @y * vector.x)
  end
  
  def divide_assign(scalar)
    self.multiply_assign(1 / scalar.to_f)
    
    return self
  end
  
  def normalize!
    if (magnitude_squared = self.squared) > 0
      self.multiply_assign(1 / Math.sqrt(magnitude_squared))
    end
  end
  
  def magnitude
    Math.sqrt(self.squared)
  end
  
  def squared
    @x**2 + @y**2 + @z**2
  end
  
  def distance_from(vector)
    Math.sqrt((@x - vector.x)**2 + (@y - vector.y)**2 + (@z - vector.z)**2)
  end
  
  private
  
  def scalar_multiplication(scalar)
    self.class.new(@x * scalar, @y * scalar, @z * scalar)
  end
  
  def dot_product(vector)
    @x * vector.x + @y * vector.y + @z * vector.z
  end
end
