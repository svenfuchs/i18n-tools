module Ruby
  module Composite
    class Array < ::Array
      include Composite

      def initialize(objects = [])
        objects.each { |object| self << object }
      end

      def <<(object)
        object = Unsupported.new(object) if object && !object.is_a?(Node)
        object.parent = self.parent unless object.parent == self.parent
        super
      end
      
      def pop
        object = super
        parent.children.delete(object) # wtf, obviously children and args are out of sync
        object
      end

      def parent=(parent)
        each { |object| object.parent = parent }
        @parent = parent
      end

      def +(other)
        self.dup.tap { |dup| other.each { |object| dup << object } }
      end
    end

    def self.included(target)
      target.class_eval do
        class << self
          def child_accessor(*names)
            names.each do |name|
              attr_reader name
              define_method("#{name}=") do |value|
                value = Composite::Array.new(value) if value.is_a?(::Array) 
                set_child(name, value)
              end
            end
          end
        end
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

    protected

      def set_child(name, value)
        value.parent = self if value
        instance_variable_set(:"@#{name}", value)
      end
  end
end