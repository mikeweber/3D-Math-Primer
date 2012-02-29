require_relative './spec_helper'

describe Matrix4x3 do
  it "should be able to create a 4x4 identity matrix" do
    identity = Matrix[[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
    Matrix4x3.identity.should == identity
  end
  
  it "should be able to create an identity matrix that utilizes the passed in translation" do
    identity_with_translation = Matrix[[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [2, 5, 3, 1]]
    
    Matrix4x3.identity(Vector[2, 5, 3]).should == identity_with_translation
  end
  
  it "should only use the first three Vector elements passed in to the translation= method" do
    identity_with_translation = Matrix[[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [2, 5, 3, 1]]
    
    identity = Matrix4x3.identity
    identity.translation = Vector[2, 5, 3, 48]
    identity.to_a.should == [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [2, 5, 3, 1]]
  end
  
  it "should be able to translate a position Vector and orientation RotationMatrix from local to parent" do
    position = Vector[3, 5, 2]
    orientation = RotationMatrix.instantiate(Matrix[
      [1,    2,    3],
      [0.5,  1.5,  2.5],
      [0.25, 0.75, 1.25]
    ])
    
    parent = Matrix4x3.local_to_parent(position, orientation)
    # the top-left 3x3 matrix should be transposed
    parent.to_a.should == [
      [1, 0.5, 0.25, 0],
      [2, 1.5, 0.75, 0],
      [3, 2.5, 1.25, 0],
      [3, 5,   2,    1]
    ]
  end
  
  it "should be able to translate a position Vector and orientation EulerAngles from local to parent" do
    position = Vector[3, 5, 2]
    orientation = EulerAngles.new(20.degrees, -45.degrees, 70.degrees).canonize
    
    # These test results rely on the RotationMatrix returning an expected result; if a bug fix causes the
    # expected RotationMatrix to change, update the expected values in the following "should" and the transposed "should"
    rm = RotationMatrix.setup(orientation)
    rm.to_a.should == [[-0.173648, -0.984808, -0.492405], [0.0, 0.0, -1.0], [0.984808, -0.173648, 0.0]]
    
    parent = Matrix4x3.local_to_parent(position, orientation)
    # the top-left 3x3 matrix should be transposed
    parent.to_a.should == [
      [-0.173648,  0,    0.984808, 0],
      [-0.984808,  0,   -0.173648, 0],
      [-0.492405, -1.0,  0,        0],
      [ 3,         5,    2,        1]
    ]
  end
  
  it "should be able to translate a position Vector and orientation RotationMatrix from parent to local" do
    position = Vector[3, 5, 2]
    orientation = RotationMatrix.instantiate(Matrix[
      [1,    2,    3],
      [0.5,  1.5,  2.5],
      [0.25, 0.75, 1.25]
    ])
    
    # This is a test of the internal logic to make sure that we will be comparing against the expected values
    expected_vector = orientation * Vector[-3, -5, -2]
    expected_vector.should == Vector[-19, -14, -7]
    
    parent = Matrix4x3.parent_to_local(position, orientation)
    
    parent.to_a.should == [
      [  1,     2,    3,    0],
      [  0.5,   1.5,  2.5,  0],
      [  0.25,  0.75, 1.25, 0],
      [-19,   -14,   -7,    1]
    ]
  end
  
  it "should be able to translate a position Vector and orientation RotationMatrix from parent to local" do
    position = Vector[3, 5, 2]
    orientation = EulerAngles.new(20.degrees, -45.degrees, 70.degrees).canonize
    
    # This is a test of the internal logic to make sure that we will be comparing against the expected values
    rm = RotationMatrix.setup(orientation)
    rm.to_a.should == [[-0.173648, -0.984808, -0.492405], [-0.0, 0.0, -1.0], [0.984808, -0.173648, -0.0]]
    expected_vector = rm * Vector[-3, -5, -2]
    expected_vector.collect { |value| value.round(6) }.should == Vector[6.429794, 2.0, -2.086184]
    
    parent = Matrix4x3.parent_to_local(position, orientation).round
    
    parent.to_a.should == [
      [-0.173648, -0.984808, -0.492405, 0],
      [ 0,         0,        -1,        0],
      [0.984808,  -0.173648,  0,        0],
      [6.429794,   2.0,      -2.086184, 1]
    ]
  end
end
