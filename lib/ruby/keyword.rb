require 'ruby/node'

module Ruby
  class Keyword < Identifier
    @@keywords = {
      'true'     => true,
      'false'    => false,
      'nil'      => nil,
      'and'      => 'and',
      'or'       => 'or',
      'not'      => 'not',
      'class'    => 'class',
      'def'      => 'def',
      'do'       => 'do',
      'end'      => 'end',
      '__FILE__' => '__FILE__',
      '__LINE__' => '__LINE__'
    }
    
    def initialize(value, position = nil)
      raise("unsupported keyword: #{value}") unless @@keywords.has_key?(value)
      super(@@keywords[value], position)
    end
    
    def to_ruby
      @@keywords.invert[value]
    end
  end
end