require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# p Ripper::SexpBuilder.new('1').parse

# src = "a && b"
# src = "!a"
# src = 't do end'
# src = "class Foo; end"
# p Ripper::SexpBuilder.new(src).parse
#
# pp Ripper::SCANNER_EVENTS
# pp ruby = Ripper::RubyBuilder.new(code).parse
#
# src = "t do |a| foo end"
# p Ripper::SexpBuilder.new(src).parse
#
# code = "t('foo')"
# Ripper::SexpBuilder.new(code).parse
# p code[3,3]

# src = "t :foo, :scope => ['bar', :'baz']"
# src = '""'
# pp Ripper::SexpBuilder.new(src).parse
# puts ruby = Ripper::RubyBuilder.new(src).parse.to_ruby

# src = "t :foo, :scope => ['bar', :'baz']"
# ruby = Ripper::RubyBuilder.new(src, 'path/to/file').parse
# p ruby.filename

# src = "t do |(a, b)| :foo end"
# src = 'a, b = c'
# src = 'a.b = 1'
# src = 'a = 1'
# p Ripper::SexpBuilder.new(src).parse
# p Ripper::RubyBuilder.new(src).parse.to_ruby
#pp Ripper::RubyBuilder.new(src).parse

# src = "[:foo]"
# Ripper::RubyBuilder.new(src).parse

# MISSING STUFF

# range
#   .. ...
#
# assignments:
#   = %= { /= -= += |= &= >>= <<= *= &&= ||= **=
#
# special:
#   defined?
#
# hash:
#   [ ] [ ]=
#
# control flow:
#   if unless while until
#   begin/end
