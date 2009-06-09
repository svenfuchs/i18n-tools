require 'ruby/assoc'

module Ruby
  class Hash < Node
    child_accessor :assocs, :ldelim, :rdelim, :separators

    def initialize(assocs, whitespace, ldelim, rdelim, separators)
      self.ldelim = ldelim
      self.rdelim = rdelim
      self.assocs = Ruby::Composite.collection(assocs)
      self.separators = Ruby::Composite.collection(separators)

      super(ldelim ? ldelim.position : assocs.first.position, whitespace)
    end
    
    def length(include_whitespace = false)
      to_ruby(include_whitespace).length
    end
    
    def [](key)
      each { |assoc| return assoc.value if assoc.key.value == key } or nil
    end
    
    def []=(key, value)
      each { |assoc| return assoc.value = value if assoc.key.value == key }
      self << Assoc.new(key, value)
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
      nodes[0].to_ruby(include_whitespace) + nodes[1..-1].map { |node| node.to_ruby(true) }.join
    end
    
    def method_missing(method, *args, &block)
      @assocs.respond_to?(method) ? @assocs.send(method, *args, &block) : super
    end
  end
end