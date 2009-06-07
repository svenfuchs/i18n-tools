require 'ruby/assoc'

module Ruby
  class Hash < Node
    attr_accessor :assocs, :ldelim, :rdelim, :separators

    def initialize(assocs, position, ldelim, rdelim, separators)
      @assocs = assocs.each { |a| a.parent = self } 
      @ldelim = ldelim if ldelim
      @rdelim = rdelim if rdelim
      @separators = separators

      super(position)
    end
    
    def children
      assocs
    end
    
    def length(include_whitespace = false)
      (ldelim ? ldelim.length(include_whitespace) : 0) + 
      assocs.inject(0) { |sum, a| sum + a.length(true) } + 
      separators.inject(0) { |sum, s| sum + s.length(true) } + 
      (rdelim ? rdelim.length(true) : 0)
    end
    
    def [](key)
      each { |assoc| return assoc.value if assoc.key.value == key }
      nil
    end
    
    def []=(key, value)
      each { |assoc| return assoc.value = value if assoc.key.value == key }
      self << Assoc.new(key, value)
      position_from(assocs.first, 2)
      self[key]
    end
    
    def delete(key)
      delete_if { |assoc| assoc.key.value == key }
    end
    
    def position
      raise "empty hash ... now what?" if empty?
      @position ||= [first.key.row, first.key.column - 2]
    end
    
    def to_hash
      eval(to_ruby(false)) rescue {}
    end

    def to_ruby
      ruby = (ldelim ? ldelim.to_ruby : '')
      ruby << zip(separators).flatten.compact.map { |el| el.to_ruby }.join
      ruby << (rdelim ? rdelim.to_ruby : '')
      ruby
    end
    
    def method_missing(method, *args, &block)
      @assocs.respond_to?(method) ? @assocs.send(method, *args, &block) : super
    end
  end
end