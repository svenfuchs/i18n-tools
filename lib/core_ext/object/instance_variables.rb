class Object
  def instance_variables_get(*keys)
    keys.inject({}) { |result, key| result[key] = instance_variable_get(:"@#{key}"); result }
  end
  
  def instance_variables_set(vars)
    vars.each { |key, value| instance_variable_set(:"@#{key}", value) }
  end
end