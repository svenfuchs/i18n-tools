$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'ripper/ruby_builder'
require 'test/unit'
require 'pp'

module TestRubyBuilderHelper
  def sexp(src)
    Ripper::SexpBuilder.new(src).parse
  end

  def build(src)
    Ripper::RubyBuilder.build(src)
  end

  def node(src, klass)
    build(src).statement { |n| n.is_a?(klass) } or nil
  end

  def array(src)
    node(src, Ruby::Array)
  end

  def hash(src)
    node(src, Ruby::Hash)
  end

  def call(src)
    node(src, Ruby::Call)
  end

  def arguments(src)
    call(src).arguments
  end

  def method(src)
    node(src, Ruby::Method)
  end
end

# class A < Array
#   def +(other)
#     self.dup.tap { |dup| other.each { |object| dup << object } }
#   end
#
#   def replace(other)
#     other = self.class.new(other) unless other.is_a?(self.class)
#     super
#   end
# end
#
# a = A.new
# a << 1 << 2
# p a
# p a.class
# a.replace([3, 4])
# p a
# p a.class
# a += [5, 6]
# p a
# p a.class
