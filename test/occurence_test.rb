require File.dirname(__FILE__) + '/test_helper'

class OccurenceTest < Test::Unit::TestCase
  def setup
    I18n::Keys.verbose = false
  end
  
  def setup
    I18n::Keys.verbose = false
    @filename = "#{File.dirname(__FILE__)}/fixtures/source_1.rb"
    FileUtils.cp(@filename, "#{@filename}.backup")
  end

  def teardown
    FileUtils.mv("#{@filename}.backup", @filename)
  end

  def occurence(key = :bar)
    index = I18n::Keys::Index.new
    index.update
    index.by_key[key.to_sym].first
  end
  
  def test_line_without_highlighting
    assert_equal "    t(:'baar')\n", occurence(:baar).line
  end
  
  def test_line_with_highlighting
    assert_equal "    t(\e[0;31;1m:'baar'\e[0m)\n", occurence(:baar).line(true)
  end
  
  def test_occurence_line_num
    assert_equal 3, occurence.line_num
  end
  
  def test_occurence_column
    assert_equal 7, occurence.column
  end
  
  def test_occurence_length
    assert_equal 4, occurence.length
  end
  
  def test_original_key
    assert ":bar", occurence.original_key
  end
  
  def test_content_head
    assert_equal "def foo\n    t(", occurence.content_head[-14, 999]
  end
  
  def test_content_tail
    assert_equal ")\n    t(:\"baaar\")\n", occurence.content_tail[0, 18]
  end
  
  def test_line_head
    assert_equal "    t(", occurence.line_head
  end
  
  def test_line_tail
    assert_equal ")\n", occurence.line_tail
  end
  
  def test_context_returns_the_context_of_the_occurence_with_2_lines_setting
    context = occurence(:baar).context.split("\n")
    assert_equal 5, context.length
    assert_equal "    t(\e[0;31;1m:'baar'\e[0m)", context[2]
  end
  
  def test_context_returns_the_context_of_the_occurence_with_3_lines_setting
    I18n::Keys::Occurence.context_lines = 3
    context = occurence(:baar).context.split("\n")
    assert_equal 7, context.length
    assert_equal "    t(\e[0;31;1m:'baar'\e[0m)", context[3]
  end
  
  def test_replace_simple_symbol_with_simple_symbol
    bar = occurence(:bar)
    bar.replace!(:oooooooo)
    assert_equal "    t(\e[0;31;1m:oooooooo\e[0m)\n", bar.line(true)
  end
  
  def test_replace_simple_symbol_with_quoted_symbol
    bar = occurence(:bar)
    bar.replace!(:'oooo.oooo')
    assert_equal "    t(\e[0;31;1m:\"oooo.oooo\"\e[0m)\n", bar.line(true)
  end
  
  def test_replace_simple_symbol_with_string
    bar = occurence(:bar)
    bar.replace!('oooooooo')
    assert_equal "    t(\e[0;31;1m:oooooooo\e[0m)\n", bar.line(true)
  end
  
  def test_replace_quoted_symbol_with_simple_symbol
    bar = occurence(:'foo.bar')
    bar.replace!(:oooooooo)
    assert_equal "    t(\e[0;31;1m:oooooooo\e[0m)\n", bar.line(true)
  end
  
  def test_replace_quoted_symbol_with_quoted_symbol
    bar = occurence(:'foo.bar')
    bar.replace!(:'oooo.oooo')
    assert_equal "    t(\e[0;31;1m:\"oooo.oooo\"\e[0m)\n", bar.line(true)
  end
  
  def test_replace_quoted_symbol_with_string
    bar = occurence(:'foo.bar')
    bar.replace!('oooooooo')
    assert_equal "    t(\e[0;31;1m:oooooooo\e[0m)\n", bar.line(true)
  end
  
  def test_replace_string_with_simple_symbol
    bar = occurence('bar_1')
    bar.replace!(:oooooooo)
    assert_equal "    t(\e[0;31;1m:oooooooo\e[0m)\n", bar.line(true)
  end
  
  def test_replace_string_with_quoted_symbol
    bar = occurence('bar_1')
    bar.replace!(:'oooo.oooo')
    assert_equal "    t(\e[0;31;1m:\"oooo.oooo\"\e[0m)\n", bar.line(true)
  end
  
  def test_replace_string_with_string
    bar = occurence('bar_1')
    bar.replace!('oooooooo')
    assert_equal "    t(\e[0;31;1m:oooooooo\e[0m)\n", bar.line(true)
  end
end