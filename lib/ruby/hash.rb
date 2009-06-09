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
    
    def nodes
      [ldelim, zip(separators), rdelim].flatten.compact
    end
    
    def method_missing(method, *args, &block)
      @assocs.respond_to?(method) ? @assocs.send(method, *args, &block) : super
    end
  end
end