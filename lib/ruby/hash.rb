require 'ruby/assoc'

module Ruby
  class Hash < Node
    child_accessor :assocs, :ldelim, :rdelim, :separators

    def initialize(assocs = nil, ldelim = nil, rdelim = nil, separators = nil)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.assocs = assocs || []
      self.separators = separators || []
    end
    
    def position
      (ldelim ? ldelim.position : assocs.first.position).dup
    end
    
    def [](key)
      each { |assoc| return assoc.value if assoc.key.value == key } or nil
    end
    
    def []=(key, value)
      each { |assoc| return assoc.value = value if assoc.key.value == key }
      self.separators << Token.new(',')
      self.assocs << Assoc.new(key, value)
      self[key]
    end
    
    def delete(key)
      delete_if { |assoc| assoc.key.value == key }
    end
    
    def value
      code = to_ruby(false)
      code = "{#{code}}" unless code =~ /^\s*{/
      eval(code) rescue {}
    end

    def to_ruby(include_whitespace = false)
      nodes = ([ldelim] + zip(separators) + [rdelim]).flatten.compact
      return '' if nodes.empty?
      nodes[0].to_ruby(include_whitespace) + nodes[1..-1].map { |node| node.to_ruby(true) }.join
    end
    
    def method_missing(method, *args, &block)
      @assocs.respond_to?(method) ? @assocs.send(method, *args, &block) : super
    end
  end
end