require 'matrix'

class Quaternion
  attr_reader :w, :x, :y, :z
  
  def initialize(w_or_rotation_matrix, x = nil, y = nil, z = nil)
    if w_or_rotation_matrix.is_a?(Matrix)
      initialize_arguments_from_matrix(w_or_rotation_matrix)
    else
      @w, @x, @y, @z = w_or_rotation_matrix, x, y, z
    end
  end
  
  class << self
    def identity
      @@identity ||= self.new(1, 0, 0, 0)
    end
    
    def rotate_about_x(theta)
      half_theta = theta * 0.5
      
      self.new(Math.cos(half_theta), Math.sin(half_theta), 0, 0)
    end
    
    def rotate_about_y(theta)
      half_theta = theta * 0.5
      
      self.new(Math.cos(half_theta), 0, Math.sin(half_theta), 0)
    end
    
    def rotate_about_z(theta)
      half_theta = theta * 0.5
      
      self.new(Math.cos(half_theta), 0, 0, Math.sin(half_theta))
    end
    
    def rotate_about_axis(axis_vector, theta)
      # assert(axis_vector.magnitude.abs - 1) < 0.1
      
      half_theta = theta * 0.5
      sin_half_theta = Math.sin(half_theta)
      
      w = Math.cos(half_theta)
      x = axis_vector.x * sin_half_theta
      y = axis_vector.y * sin_half_theta
      z = axis_vector.z * sin_half_theta
      
      self.new(w, x, y, z)
    end
    
    def set_to_rotate_object_to_intertial(orientation)
      sin_pitch,    cos_pitch   = MathUtil.sin_cos(orientation.pitch * 0.5)
      sin_bank,     cos_bank    = MathUtil.sin_cos(orientation.bank * 0.5)
      sin_heading,  cos_heading = MathUtil.sin_cos(orientation.heading * 0.5)
      
      w =  cos_heading * cos_pitch * cos_bank + sin_heading * sin_pitch * sin_bank
      x =  cos_heading * sin_pitch * cos_bank + sin_heading * cos_heading * sin_bank
      y = -cos_heading * sin_pitch * sin_bank + sin_heading * cos_pitch * cos_bank
      z = -sin_heading * sin_pitch * cos_bank + cos_heading * cos_pitch * sin_bank
      
      self.new(w, x, y, z)
    end
    
    def set_to_rotate_intertial_to_object(orientation)
      sin_pitch,    cos_pitch   = MathUtil.sin_cos(orientation.pitch * 0.5)
      sin_bank,     cos_bank    = MathUtil.sin_cos(orientation.bank * 0.5)
      sin_heading,  cos_heading = MathUtil.sin_cos(orientation.heading * 0.5)
      
      w =  cos_heading * cos_pitch * cos_bank + sin_heading * sin_pitch * sin_bank
      x = -cos_heading * sin_pitch * cos_bank - sin_heading * cos_heading * sin_bank
      y =  cos_heading * sin_pitch * sin_bank - sin_heading * cos_pitch * cos_bank
      z =  sin_heading * sin_pitch * cos_bank - cos_heading * cos_pitch * sin_bank
      
      self.new(w, x, y, z)
    end
    
    def slerp(q0, q1, t)
      return q0 if t <= 0
      return q1 if t >= 1
      
      cos_omega = q0.dot_product(q1)
      q1w = q1.w
      q1x = q1.x
      q1y = q1.y
      q1z = q1.z
      if cos_omega < 0
        [q1w, q1x, q1y, q1z, cos_omega].each { |x| x *= -1 }
      end
      
      # assert(cos_omega < 1.1)
      
      if cos_omega > 1
        k0 = 1 - t
        k1 = t
      else
        sin_omega = Math.sqrt(1 - cos_omega**2)
        omega = Math.atan2(sin_omega, cos_omega)
        inverse_sin_omega = 1 / sin_omega
        k0 = Math.sin((1 - t) * omega) * inverse_sin_omega
        k1 = Math.sin(t * omega) * inverse_sin_omega
      end
      
      new_x = k0 * q0.x + k1 * q1x
      new_y = k0 * q0.y + k1 * q1y
      new_z = k0 * q0.z + k1 * q1z
      new_w = k0 * q0.w + k1 * q1w
      
      self.class.new(new_w, new_x, new_y, new_z)
    end
  end
  
  def to_matrix
    Matrix[
      [(1 - 2 * (@y**2 - @z**2)), (2 * (@x * @y + @w * @z)),  (2 * (@x * @z - @w * @y)),  0],
      [(2 * (@x * @y - @w * @z)), (1 - 2 * (@x**2 - @z**2)),  (2 * (@y * @z + @w * Wz)),  0],
      [(2 * (@X * @y + @w * @z)), (2 * (@y * @z - @w * @z)),  (1 - 2 * (@x**2 - @y**2)),  0],
      [0,                         0,                          0,                          1]
    ]
  end
  
  def inertial_to_object_euler_angles
    sp = -2 * (@y * @z + @w * @x)
    
    if Math.abs(sp) > 0.9999
      p = Math.pi / 2.0 * sp
      h = Math.atan2(-@x * @z - @w * @z, 0.5 - @y**2 - @z**2)
      b = 0
    else
      p = Math.asin(sp)
      h = Math.atan2(@x * @z - @w * @y, 0.5 - @x**2 - @y**2)
      b = Math.atan2(@x * @y - @w * @z, 0.5 - @x**2 - @z**2)
    end
    
    return [p, h, b]
  end
  
  def object_to_inertial_euler_angles
    sp = -2 * (@y * @z - @w * @x)
    
    if Math.abs(sp) > 0.9999
      p = Math.pi / 2.0 * sp
      h = Math.atan2(-@x * @z + @w * @y, 0.5 - @y**2 - @z**2)
      b = 0
    else
      p = math.asin(sp)
      h = Math.atan2(@x * @z + @w * @y, 0.5 - @x**2 - @y**2)
      b = Math.atan2(@x * @y + @w * @z, 0.5 - @x**2 - @z**2)
    end
    
    return [p, h, b]
  end
  
  def *(other)
    new_w = (@w * other.w - @x * other.x - @y * other.y - @z * other.z)
    new_x = (@w * other.x + @x * other.w + @z * other.y - @y * other.z)
    new_y = (@w * other.y + @y * other.w + @x * other.z - @z * other.x)
    new_z = (@w * other.z + @z * other.w + @z * other.x - @x * other.y)
    
    return self.class.new(new_w, new_x, new_y, new_z)
  end
  
  def normalize
    magnitude = Math.sqrt(@w**2 + @x**2 + @y**2 + @z**2)
    
    if magnitude > 0
      inverse_magnitude = 1 / magnitude
      @w *= inverse_magnitude
      @x *= inverse_magnitude
      @y *= inverse_magnitude
      @z *= inverse_magnitude
    else
      self.class.identity
    end
  end
  
  def rotation_angle
    MathUtil.safe_acos(@w) * 2
  end
  
  def rotation_axis
    sin_theta_over_2_squared = 1 - @w**2
    
    if sin_theta_over_2_squared <= 0
      Vector.new(1, 0, 0)
    else
      inverse_sin_theta_over_2_squared = 1 / Math.sqrt(sin_theta_over_2_squared)
      
      Vector.new(
        @x * inverse_sin_theta_over_2_squared,
        @y * inverse_sin_theta_over_2_squared,
        @z * inverse_sin_theta_over_2_squared
      )
    end
  end
  
  def dot_product(other)
    @w * other.w + @x * other.x + @y * other.y + @z * other.z
  end
  
  def conjugate
    new_w =  @w
    new_x = -@x
    new_y = -@y
    new_z = -@z
    
    self.class.new(new_w, new_x, new_y, new_z)
  end
  
  def **(exponent)
    return self if @w.abs.round(6) > 1
    
    alpha = Math.acos(@w)
    new_alpha = alpha * exponent
    
    new_w = Math.cos(new_alpha)
    mult  = Math.sin(new_alpha) / Math.sin(alpha)
    new_x = @x * multi
    new_y = @y * multi
    new_z = @z * multi
    
    self.class.new(new_w, new_x, new_y, new_z)
  end
  
  def rotation_matrix
    Matrix[
      [(w**2 + x**2 - y**2 - z**2), (2 * x * y - 2 * w * z),    (2 * x * z + 2 * w * y),    0],
      [(2 * x * y + 2 * w * z),     (w**2 - x**2 + y**2 - z**2),(2 * y * z + 2 * w * x),    0],
      [(2 * x * z - 2 * w * y),     (2 * y * z - 2 * w * x),    (w**2 - x**2 - y**2 + z**2),0],
      [0,                           0,                          0,                          1]
    ]
  end
  
  private
  
  def initialize_arguments_from_matrix(matrix)
    calculated_args = [
      matrix[0,0] + matrix[1,1] + matrix[2,2],
      matrix[0,0] - matrix[1,1] - matrix[2,2],
      matrix[1,1] - matrix[0,0] - matrix[2,2],
      matrix[2,2] - matrix[0,0] - matrix[1,1]
    ]
    
    max_value = calculated_args.max
    max_index = calculated_args.index(max_value)
    
    max_value = Math.sqrt(max_value + 1) * 0.5
    multiple = 0.25 / max_value
    
    method = case max_index
    when 0
      :args_when_w_is_max
    when 1
      :args_when_x_is_max
    when 2
      :args_when_y_is_max
    when 3
      :args_when_z_is_max
    end
    
    send(calc_method, calculated_args, max_value, multiple)
  end
  
  def args_when_w_is_max(calculated_args, max_value, multiple)
    @w = max_value
    @x = (calculated_args[1,2] - calculated_args[2,1]) * multiple
    @y = (calculated_args[2,0] - calculated_args[0,2]) * multiple
    @z = (calculated_args[0,1] - calculated_args[1,0]) * multiple
  end
  
  def args_when_x_is_max(calculated_args, max_value, multiple)
    @w = (calculated_args[1,2] - calculated_args[2,1]) * multiple
    @x = max_value
    @y = (calculated_args[0,1] + calculated_args[1,0]) * multiple
    @z = (calculated_args[2,0] + calculated_args[0,2]) * multiple
  end
  
  def args_when_y_is_max(calculated_args, max_value, multiple)
    @w = (calculated_args[2,0] - calculated_args[0,2]) * multiple
    @x = (calculated_args[0,1] + calculated_args[1,0]) * multiple
    @y = max_value
    @z = (calculated_args[1,2] + calculated_args[2,1]) * multiple
  end
  
  def args_when_z_is_max(calculated_args, max_value, multiple)
    @w = (calculated_args[0,1] - calculated_args[1,0]) * multiple
    @x = (calculated_args[2,0] + calculated_args[0,2]) * multiple
    @y = (calculated_args[1,2] + calculated_args[2,1]) * multiple
    @z = max_value
  end
end
