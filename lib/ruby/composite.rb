module Ruby
  module Composite
    class << self
      def included(target)
        target.send(:extend, Ruby::Composite::ClassMethods)
      end
      
      def collection(object = nil)
         collection?(object) ? object : Collection.new(Array(object))
      end
      
      def collection?(object)
        object.class.include?(Composite) && object.respond_to?(:each)
      end
    end
    
    module ClassMethods
      def child_accessor(*names)
        names.each do |name|
          attr_reader name
          class_eval <<-eoc
            def #{name}=(#{name})                 # def key=(key)
              #{name}.parent = self if #{name}    #   key.parent = self if key
              @#{name} = #{name}                  #   @key = key
            end                                   # end
          eoc
        end
      end
    end
  
    class Collection < Array
      include Composite
    
      def initialize(objects = [])
        objects.each { |object| self << object }
      end
    
      def <<(object)
        object = Unsupported.new(object) if object && !object.is_a?(Node)
        object.parent = self.parent unless object.parent == self.parent
        super
      end
      
      def parent=(parent)
        each { |object| object.parent = parent }
        @parent = parent
      end
    
      def +(other)
        self.dup.tap { |dup| other.each { |object| dup << object } }
      end
    end

    attr_reader :parent
    
    def parent=(parent)
      @parent.children.delete(self) if @parent
      @parent = parent 
      parent.children << self if parent && !parent.children.include?(self)
    end
    
    def children
      @children ||= []
    end

    def root?
      parent.nil?
    end

    def root
      root? ? self : parent.root
    end
  end
end