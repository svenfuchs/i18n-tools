require File.dirname(__FILE__) + '/test_helper'
require 'erb'

class ErbParserTest < Test::Unit::TestCase
  def setup
    @erb = File.read("#{File.dirname(__FILE__)}/fixtures/template.html.erb")
    @ruby = I18n::ErbParser.new.to_ruby(@erb)
    @expected = <<-src
   f.field_set do
	   column do
		   [:foo].each do |foo|
				          t(:erb_1)
		   end
		    t(:erb_2)
		   t(:'foo.erb_3')
	   end
   end
    src
  end

  def test_sexp_filename
    assert_equal @erb.length, @ruby.length
    %w(erb_1 erb_2 foo.erb_3).each do |token|
      assert @ruby.index(token)
      assert_equal @erb.index(token), @ruby.index(token)
    end
    @expected.split("\n").each do |token|
      assert @ruby.index(token)
    end
  end
end
