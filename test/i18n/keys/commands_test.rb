require File.dirname(__FILE__) + '/../../test_helper'

class I18nKeysCommandsTest < Test::Unit::TestCase
  def setup
    @keys = keys
  end

  define_method :"test find command" do
    filename = '/source_1.rb'
    @keys.find('baaar', options(filename))
    assert_output('baaar', 3, 4, filename)
  end
  
  protected
  
    def assert_output(key, row, column, filename)
      assert_match @keys.string, %r(#{key})
      assert_match @keys.string, %r(\e\[0;31;1mt.*#{key}.*\e\[0m)
      assert_match @keys.string, %r(#{filename} \[#{row}/#{column}\])
    end
  
    def keys
      keys = I18n::Commands::Keys.new
      stub_puts(keys)
    end
  
    def options(filename)
      { :dir => File.expand_path(File.dirname(__FILE__) + '/../../fixtures'),
        :pattern => filename }
    end
  
    def stub_puts(target)
      (class << target; self; end).class_eval do 
        attr_accessor :out
        define_method(:puts) { |str| out.puts(str) }
        define_method(:string) { out.string }
      end
      target.out = StringIO.new
      target
    end
end