class Hash
  def each_nested(data = nil, keys = [], &block)
    (data || self).each do |key, value|
      case value
      when Hash
        each_nested(value, keys + [key], &block)
      else
        yield(keys + [key], value)
      end
    end
  end

  def select_nested(data = self, keys = [], &block)
    case data
    when Hash
      data.inject({}) do |result, (key, value)|
        value = select_nested(value, keys + [key], &block)
        result[key] = value unless value.nil? || value.empty?
        result
      end
    else
      data if yield(keys, data)
    end
  end
  
  def delete_nested_if(data = self, keys = [], &block)
    data.each do |key, value|
      if yield(keys + [key], value)
        data.delete(key)
      else
        delete_nested_if(value, keys + [key], &block)
      end
    end if data.is_a?(Hash)
  end
end