Sexp.class_eval do
  attr_accessor :full_source, :source_start_pos, :source_end_pos
  
  def initialize_copy(object)
    object.each do |element|
      self << (element.is_a?(Symbol) ? element : element.clone)
    end
  end

  def to_ruby
    Ruby2Ruby.new.process self
  end
  
  def value
    self[1]
  end
  
  def arglist
    self[3] if self[3] && self[3][0] == :arglist
  end

  def source_range
    source_start_pos..source_end_pos if source_start_pos && source_end_pos
  end

  def source
    full_source[source_range] if full_source && source_range
  end
  
  def find_by_type(type)
    nodes = []
    nodes << self if self.first == type
    each_of_type(type) { |node| nodes << node }
    nodes
  end
  
  def each_key_node(&block)
    each do |element|
      next unless Sexp === element
      element.each_key_node(&block)
      block.call(element) if element.is_key_node?
    end
  end
  
  def is_key_node?
    first == :str || first == :lit && self[1].is_a?(Symbol)
  end
end