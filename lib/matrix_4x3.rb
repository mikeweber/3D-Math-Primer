require 'matrix'

class Matrix4x3 < Matrix
  class << self
    # Using 'extend' rather than relying on normal inheritence since there is a bug in how Matrix is implemented
    # http://stackoverflow.com/questions/6064902/copy-inheritance-of-ruby-matrix-class-core-std-lib
    def instantiate(matrix)
      matrix_4x3 = Matrix[*matrix.to_a]
      matrix_4x3.extend Matrix4x3InstanceMethods
      matrix_4x3.normalize
    end
    
    def identity(vector = nil)
      matrix_4x3 = self.instantiate(super(4))
      matrix_4x3.translation = vector if vector
      matrix_4x3
    end
    
    def local_to_parent(position_vector, orientation)
      rotation_matrix = orientation.is_a?(EulerAngles) ? RotationMatrix.setup(orientation) : orientation
      
      local_to_parent_matrix = self.instantiate(rotation_matrix.transpose)
      local_to_parent_matrix.translation = position_vector
      
      return local_to_parent_matrix
    end
    
    def parent_to_local(position_vector, orientation)
      rotation_matrix = orientation.is_a?(EulerAngles) ? RotationMatrix.setup(orientation) : orientation
      
      parent_to_local_matrix = self.instantiate(rotation_matrix)
      translation_rotation = rotation_matrix * (-1 * position_vector)
      
      parent_to_local_matrix.translation = translation_rotation
      
      return parent_to_local_matrix
    end
    
    def rotate(axis, theta)
      raise "Invalid axis" unless axis.is_a?(Vector) || [:x, :y, :z].include?(axis.to_sym)
      
      sin_theta, cos_theta = MathUtil.sin_cos(theta)
      if axis.is_a?(Vector)
        rotate_arbitrarily(axis, sin_theta, cos_theta)
      else
        # Rotate around the specified axis, passing in the sin and cosine values for the specified theta
        send("rotate_#{axis}", sin_theta, cos_theta)
      end
    end
    
    def from_quaternion(quaternion)
      ww = 2 * quaternion.w
      xx = 2 * quaternion.x
      yy = 2 * quaternion.y
      zz = 2 * quaternion.z
      
      m11 = 1 - yy * quaternion.y - zz * quaternion.z
      m12 = xx * quaternion.y + ww * quaternion.z
      m13 = xx * quaternion.z - ww * quaternion.x
      
      m21 = xx * quaternion.y - ww * quaternion.z
      m22 = 1 - xx * quaternion.x - zz * quaternion.z
      m23 = yy * quaternion.z + ww * quaternion.x
      
      m31 = xx * quaternion.z + ww * quaternion.y
      m32 = yy * quaternion.z - ww * quaternion.x
      m33 = 1 - xx * quaternion.x - yy * quaternion.y
      
      self.instantiate([
        [m11, m12, m13],
        [m21, m22, m23],
        [m31, m32, m33]
      ])
    end
    
    def scale(vector)
      self.instantiate([
        [vector.x, 0,        0],
        [0,        vector.y, 0],
        [0,        0,        vector.z]
      ])
    end
    
    def scale_along_axis(factor, axis)
      raise "Only Unit Vectors are accepted" unless (axis * axis).round(6) < 1
      
      a = factor - 1
      ax = a * axis.x
      ay = a * axis.y
      az = a * axis.z
      
      m11 = ax * axis.x + 1
      m22 = ay * axis.y + 1
      m32 = az * axis.z + 1
      
      m12 = m21 = ax * axis.y
      m13 = m31 = ax * axis.z
      m23 = m32 = ay * axis.z
      
      self.instantiate([
        [m11, m12, m13],
        [m21, m22, m23],
        [m31, m32, m33]
      ])
    end
    
    private
    
    def rotate_arbitrarily(axis, s, c)
      raise "Only Unit Vectors are accepted" unless (axis * axis).round(6) < 1
      
      a  = 1 - c
      ax = a * axis.x
      ay = a * axis.y
      az = a * axis.z
      
      m11 = ax * axis.x + c
      m12 = ax * axis.y + axis.z * s
      m13 = ax * axis.z - axis.y * s
      
      m21 = ay * axis.x - axis.z * s
      m22 = ay * axis.y + c
      m23 = ay * axis.z + axis.x * s
      
      m31 = az * axis.x + axis.y * s
      m32 = az * axis.y - axis.x * s
      m33 = az * axis.z + c
      
      self.instantiate([
        [m11, m12, m13],
        [m21, m22, m23],
        [m31, m32, m33]
      ])
    end
    
    def rotate_x(s, c)
      self.instantiate([
        [1,  0, 0, 0],
        [0,  c, s, 0],
        [0, -s, c, 0]
      ])
    end
    
    def rotate_y(s, c)
      self.instantiate([
        [c, 0, -s, 0],
        [0, 1,  0, 0],
        [s, 0,  c, 0]
      ])
    end
    
    def rotate_z(s, c)
      self.instantiate([
        [ c, s, 0, 0],
        [-s, c, 0, 0],
        [ 0, 0, 1, 0]
      ])
    end
  end
end

module Matrix4x3InstanceMethods
  def translation=(vector)
    @rows[self.row_size - 1] = [*vector.to_a[0..2], 1]
    return self
  end
  
  def normalize
    # Make sure each row has 4 columns
    @rows.each_with_index do |v, i|
      @rows[i] = ([0] * 4).zip(v.to_a).collect { |x, y| y || x }
    end
    
    # Make sure there are at least 3 rows
    while @rows.size < 3
      @rows << ([0] * 4)
    end
    
    # If there are 3 rows at this point, add a 4th and set it as the translation
    if @rows.size == 3
      @rows << ([0] * 4)
      self.translation = [0, 0, 0]
    end
    
    return self
  end
  
  def round(precision = 6)
    @rows.collect! { |row| row.collect { |value| value.round(precision) } }
  end
end
