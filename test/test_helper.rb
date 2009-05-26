require 'test/unit'
require File.dirname(__FILE__) + '/../lib/i18n/keys'

class String
  def to_sexp
    I18n::RubyParser.new.parse(self)
  end
end

class Sexp
  def find_node(type)
    each_of_type(type) { |node| return node }
  end
end