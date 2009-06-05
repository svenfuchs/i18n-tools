require File.dirname(__FILE__) + '/test_helper'

class RipperRubyBuilderCallsTest < Test::Unit::TestCase
  def statements(src)
    Ripper::RubyBuilder.build(src).statements
  end
  
  def test_src_pos
    statements = statements("  aaaaaaa\nbbbbb\ncccc(:c)\nddd\nee\nf")
    assert_equal 2,  statements[0].src_pos
    assert_equal 10, statements[1].src_pos
    assert_equal 16, statements[2].src_pos
    assert_equal 21, statements[2].arguments.first.src_pos
    assert_equal 25, statements[3].src_pos
    assert_equal 29, statements[4].src_pos
    assert_equal 32, statements[5].src_pos
  end
end