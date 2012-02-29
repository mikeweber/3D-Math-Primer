require 'math_util'

class EulerAngles
  attr_reader :heading, :pitch, :bank
  
  def initialize(h, p, b)
    @heading  = h
    @pitch    = p
    @bank     = b
  end
  
  # class << self
    def from_object_to_inertial_quaternion(quaternion)
      sin_pitch = (-2 * (quaternion.y * quaternion.z - quaternion.w * quaternion.x)).round(6)
      
      if sin_pitch.abs > 1
        @pitch    = MathUtil.quarter_tau * sin_pitch
        @heading  = Math.atan2((-quaternion.x * quaternion.z + quaternion.w * quaternion.y), (0.5 - quaternion.y**2 - quaternion.z**2))
        @bank     = 0
      else
        @pitch    = Math.asin(sin_pitch)
        @heading  = Math.atan2((quaternion.x * quaternion.z + quaternion.w * quaternion.y), (0.5 - quaternion.x**2 - quaternion.y**2))
        @bank     = Math.atan2((quaternion.x * quaternion.y + quaternion.w * quaternion.z), (0.5 - quaternion.x**2 - quaternion.z**2))
      end
    end
    
    def from_inertial_to_object_quaternion(quaternion)
      sin_pitch = (-2 * (quaternion.y * quaternion.z + quaternion.w * quaternion.x))
      
      if sin_pitch.abs > 1
        @pitch    = MathUtil.quarter_tau * sin_pitch
        @heading  = Math.atan2((-quaternion.x * quaternion.z - quaternion.w * quaternion.y), (0.5 - quaternion.y**2 - quaternion.z**2))
        @bank     = 0
      else
        @pitch    = Math.asin(sin_pitch)
        @heading  = Math.atan2((quaternion.x * quaternion.z - quaternion.w * quaternion.y), (0.5 - quaternion.x**2 - quaternion.y**2))
        @bank     = Math.atan2((quaternion.x * quaternion.y - quaternion.w * quaternion.z), (0.5 - quaternion.x**2 - quaternion.z**2))
      end
    end
    
    def from_object_to_world_matrix(matrix)
      sin_pitch = -matrix[2, 1]
      
      if sin_pitch.abs > 1
        @pitch    = MathUtil.quarter_tau * sin_pitch
        @heading  = Math.atan2(-matrix[1, 2], matrix[0, 0])
        @bank     = 0
      else
        @pitch    = Math.atan2(matrix[2, 0], matrix[2, 2])
        @heading  = Math.asin(sin_pitch)
        @bank     = Math.atan2(matrix[0, 1], matrix[1, 1])
      end
    end
    
    def from_world_to_object_matrix(matrix)
      sin_pitch = -matrix[1, 2]
      
      if sin_pitch.abs > 1
        @pitch    = MathUtil.quarter_tau * sin_pitch
        @heading  = Math.atan2(-matrix[2, 0], matrix[0, 0])
        @bank     = 0
      else
        @heading  = Math.atan2(matrix[0, 2], matrix[2, 2])
        @pitch    = Math.asin(sin_pitch)
        @bank     = Math.atan2(matrix[1, 0], matrix[1, 1])
      end
    end
    
    def from_rotation_matrix(rotation_matrix)
      sin_pitch = -matrix[1, 2]
      
      if sin_pitch.abs > 1
        @pitch    = MathUtil.quarter_tau * sin_pitch
        @heading  = Math.atan2(-matrix[2, 0], matrix[0, 0])
        @bank     = 0
      else
        @heading  = Math.atan2(matrix[0, 2], matrix[2, 2])
        @pitch    = Math.asin(sin_pitch)
        @bank     = Math.atan2(matrix[1, 0], matrix[1, 1])
      end
    end
  # end
  
  def identity
    @heading = @pitch = @bank = 0
  end
  
  def canonize
    @pitch = MathUtil.wrap_tau(@pitch).round(6)
    
    if @pitch < -MathUtil.quarter_tau
      @pitch     = -MathUtil.half_tau.round(6) - @pitch
      @heading  +=  MathUtil.half_tau.round(6)
      @bank     +=  MathUtil.half_tau.round(6)
    elsif @pitch >  MathUtil.quarter_tau
      @pitch     =  MathUtil.half_tau.round(6) - @pitch
      @heading  +=  MathUtil.half_tau.round(6)
      @bank     +=  MathUtil.half_tau.round(6)
    end
    
    # Check for gimbal lock
    if @pitch.abs > MathUtil.quarter_tau
      @heading += @bank
      @bank = 0
    else
      @bank = MathUtil.wrap_tau(@bank).round(6)
    end
    
    @heading = MathUtil.wrap_tau(@heading).round(6)
    
    return self
  end
end
