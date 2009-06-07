require File.dirname(__FILE__) + '/../test_helper'

class RipperRubyBuilderCallsTest < Test::Unit::TestCase
  include TestRubyBuilderHelper

  define_method :"test call on no target without arguments but parantheses" do
    src = "t('foo')"
    call = call(src)

    assert_equal 't', call.token
    assert !call.target
    assert call.parent.is_a?(Ruby::Program)
    
    assert_equal src, call.root.src
    assert_equal src, call.to_ruby
  end
end