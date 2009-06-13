class Hash
  attr_accessor :to_yaml_style
  
  def set_yaml_style(style)
    self.to_yaml_style = style
    each { |key, value| value.set_yaml_style(style) if value.is_a?(Hash) }
  end

  def to_yaml(opts = {})
    YAML::quick_emit(object_id, opts) do |out|
      out.map(taguri, to_yaml_style) do |map|
        elements = to_yaml_style == :sorted ? sort : self
        elements.each { |k, v| map.add(k, v) }
      end
    end
  end
end