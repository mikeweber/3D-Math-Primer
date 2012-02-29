class Vector3 < Vector
  def x
    self[0]
  end
  
  def x=(val)
    self[0] = val
  end
  
  def y
    self[1]
  end
  
  def y=(val)
    self[1] = val
  end
  
  def z
    self[2]
  end
  
  def z=(val)
    self[2] = val
  end
  
  def clear!
    self.x = self.y = self.z = 0
    
    return self
  end
  
  def inverse
    self.class.new(-self.x, -self.y, -self.z)
  end
  
  def cross_product(vector)
    self.class.new(@y * vector.z - @z * vector.y, @z * vector.x - @x * vector.z, @x * vector.y - @y * vector.x)
  end
  
  def normalize!
    if (self.squared) > 0
      self.each.with_index do |el, index|
        self[index] *= (1 / self.magnitude)
      end
    end
  end
  
  def squared
    @x**2 + @y**2 + @z**2
  end
  
  def distance_from(vector)
    Math.sqrt((@x - vector.x)**2 + (@y - vector.y)**2 + (@z - vector.z)**2)
  end
end
