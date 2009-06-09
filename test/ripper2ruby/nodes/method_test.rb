# require File.dirname(__FILE__) + '/../test_helper'
# 
# class RipperRubyBuilderMethodTest < Test::Unit::TestCase
#   include TestRubyBuilderHelper
# 
#   define_method :"test a method" do
#     src = <<-eoc
#       def foo
#         bar
#       end
#     eoc
#     src = src.strip
#     method = method(src)
#   end
# end