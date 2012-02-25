require 'matrix'

class Quaternion
  attr_accessor :w, :x, :y, :z
  
  def initialize(w_or_rotation_matrix, x = nil, y = nil, z = nil)
    if w_or_rotation_matrix.is_a?(Matrix)
      initialize_arguments_from_matrix(w_or_rotation_matrix)
    else
      @w, @x, @y, @z = w_or_rotation_matrix, x, y, z
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
    new_x = (@w * other.x + @x * other.w + @y * other.z - @z * other.y)
    new_y = (@w * other.y - @x * other.z + @y * other.w + @z * other.x)
    new_z = (@w * other.z + @x * other.y - @y * other.x + @z * other.w)
    
    return self.class.new(new_w, new_x, new_y, new_z)
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
