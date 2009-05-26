require File.dirname(__FILE__) + '/test_helper'
require 'erb'

class ErbParserTest < Test::Unit::TestCase
  def test_sexp_filename
    erb = File.read("#{File.dirname(__FILE__)}/fixtures/template.html.erb")
    ruby = I18n::ErbParser.new.to_ruby(erb)
    assert_equal erb.length, ruby.length
    %w(erb_1 erb_2 foo.erb_3).each do |key|
      assert ruby.index(key)
      assert_equal erb.index(key), ruby.index(key)
    end
  end
end
