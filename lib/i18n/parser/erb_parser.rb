# replaces html and erb tags with whitespace so that we can parse the result
# as pure ruby preserving the exact positions of tokens in the original erb
# source code

require 'erb'
$KCODE = 'u'

class String
  def to_whitespace
    gsub(/[^\s;]/, ' ')
  end
end

module I18n
  class ErbParser
    class Scanner < ERB::Compiler::Scanner
      def scan
        stag_reg = /(.*?)(^[ \t]*<%%|<%=|<%#|<%-|<%|\z)/m
        etag_reg = /(.*?)(%%>|\-%>|%>|\z)/m
        scanner = StringScanner.new(@src)
        while !scanner.eos?
          scanner.scan(@stag ? etag_reg : stag_reg)
          yield(scanner[1]) unless scanner[1].nil?
          yield(scanner[2]) unless scanner[2].nil?
        end
      end
    end
    ERB::Compiler::Scanner.regist_scanner(Scanner, nil, false)

    def to_ruby(source)
      result = ''
      comment = false
      scanner = ERB::Compiler.new(nil).make_scanner(source)
      scanner.scan do |token|
        comment = true if token == '<%#'
        if scanner.stag.nil?
          result << token.to_whitespace
          scanner.stag = token if ['<%', '<%-', '<%=', '<%#'].include?(token)
        elsif ['%>', '-%>'].include?(token)
          result << token.gsub(/>/, ';').to_whitespace
          scanner.stag = nil
        else
          result << (comment ? token.to_whitespace : token) # so, this is the ruby code, then
          comment = false
        end
      end
      result
    end
    
    def content_dump(string)
      string.split("\n").map { |s| s.to_whitespace }.join("\n")
    end
  end
end