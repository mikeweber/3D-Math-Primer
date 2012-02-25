class Float
  def *(vector)
    if vector.is_a?(Vector)
      vector * self
    else
      super(vector)
    end
  end
end
