require File.dirname(__FILE__) + '/../test_helper'

class RipperRubyBuilderArgsTest < Test::Unit::TestCase
  include TestRubyBuilderHelper

  define_method :"test a block with arguments" do
    src = <<-eoc
      t do |(a, b), *c|    
        foo
        bar
      end
    eoc
    src = src.strip
    block = call(src).block
    assert_equal src, 't' + block.to_ruby(true)
  end
end