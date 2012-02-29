require 'matrix'
require 'math_util'

class RotationMatrix < Matrix
  class << self
    # Using 'extend' rather than relying on normal inheritence since there is a bug in how Matrix is implemented
    # http://stackoverflow.com/questions/6064902/copy-inheritance-of-ruby-matrix-class-core-std-lib
    def instantiate(matrix)
      rotation_matrix = Matrix[*matrix.to_a]
      rotation_matrix.extend RotationMatrixInstanceMethods
    end
    
    def identity
      self.instantiate(super(3))
    end
    
    def setup(orientation)
      sin_heading,  cos_heading = MathUtil.sin_cos(orientation.heading)
      sin_pitch,    cos_pitch   = MathUtil.sin_cos(orientation.pitch)
      sin_bank,     cos_bank    = MathUtil.sin_cos(orientation.bank)
      
      m11 =  cos_heading * cos_bank + sin_heading * sin_pitch * sin_bank
      m12 = -cos_heading * sin_bank + sin_heading * sin_pitch * cos_bank
      m13 =  sin_heading * cos_bank
      
      m21 =  sin_bank * cos_pitch
      m22 =  cos_bank * cos_pitch
      m23 = -sin_pitch
      
      m31 = -sin_heading * cos_bank + cos_heading * sin_pitch * sin_bank
      m32 =  sin_bank * sin_heading + cos_heading * sin_pitch * cos_bank
      m33 =  cos_heading * cos_pitch
      
      self.instantiate([
        [m11.round(6), m12.round(6), m13.round(6)],
        [m21.round(6), m22.round(6), m23.round(6)],
        [m31.round(6), m32.round(6), m33.round(6)]
      ])
    end
    
    def from_inertial_to_object_quaternion(quaternion)
      m11 = 1 - 2 * (quaternion.y**2 + quaternion.z**2)
      m12 = 2 * (quaternion.x * quaternion.y + quaternion.w * quaternion.z)
      m13 = 2 * (quaternion.x * quaternion.z + quaternion.w * quaternion.y)
      
      m21 = 2 * (quaternion.x * quaternion.y - quaternion.w * quaternion.z)
      m22 = 1 - 2 * (quaternion.x**2 + quaternion.z**2)
      m23 = 2 * (quaternion.y * quaternion.z + quaternion.w * quaternion.x)
      
      m31 = 2 * (quaternion.x * quaternion.z + quaternion.w * quaternion.y)
      m32 = 2 * (quaternion.y * quaternion.z - quaternion.w * quaternion.x)
      m33 = 1 - 2 * (quaternion.x**2 + quaternion.y**2)
      
      self.instantiate([
        [m11.round(6), m12.round(6), m13.round(6)],
        [m21.round(6), m22.round(6), m23.round(6)],
        [m31.round(6), m32.round(6), m33.round(6)]
      ])
    end
    
    def from_object_to_inertial_quaternion(quaternion)
      m11 = 1 - 2 * (quaternion.y**2 + quaternion.z**2)
      m12 = 2 * (quaternion.x * quaternion.y - quaternion.w * quaternion.z)
      m13 = 2 * (quaternion.x * quaternion.z + quaternion.w * quaternion.y)
      
      m21 = 2 * (quaternion.x * quaternion.y + quaternion.w * quaternion.z)
      m22 = 1 - 2 * (quaternion.x**2 + quaternion.z**2)
      m23 = 2 * (quaternion.y * quaternion.z - quaternion.w * quaternion.x)
      
      m31 = 2 * (quaternion.x * quaternion.z - quaternion.w * quaternion.y)
      m32 = 2 * (quaternion.y * quaternion.z + quaternion.w * quaternion.x)
      m33 = 1 - 2 * (quaternion.x**2 + quaternion.y**2)
      
      self.instantiate([
        [m11.round(6), m12.round(6), m13.round(6)],
        [m21.round(6), m22.round(6), m23.round(6)],
        [m31.round(6), m32.round(6), m33.round(6)]
      ])
    end
  end
  
end

module RotationMatrixInstanceMethods
  
  def inertial_to_object(vector)
    Vector.new(
      self[0, 0] * vector.x + self[1, 0] * vector.y + self[2, 0] * vector.z,
      self[0, 1] * vector.x + self[1, 1] * vector.y + self[2, 1] * vector.z,
      self[0, 2] * vector.x + self[1, 2] * vector.y + self[2, 2] * vector.z
    )
  end
  
  def object_to_inertial(vector)
    Vector.new(
      self[0, 0] * vector.x + self[0, 1] * vector.y + self[0, 2] * vector.z,
      self[1, 0] * vector.x + self[1, 1] * vector.y + self[1, 2] * vector.z,
      self[2, 0] * vector.x + self[2, 1] * vector.y + self[2, 2] * vector.z
    )
  end
end
