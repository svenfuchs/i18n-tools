#  from activesupport

class Module
  def mattr_reader(*syms)
    syms.each do |sym|
      next if sym.is_a?(Hash)
      class_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}  # unless defined? @@pagination_options
          @@#{sym} = nil          #   @@pagination_options = nil
        end                       # end
                                  #
        def self.#{sym}           # def self.pagination_options
          @@#{sym}                #   @@pagination_options
        end                       # end
                                  #
        def #{sym}                # def pagination_options
          @@#{sym}                #   @@pagination_options
        end                       # end
      EOS
    end
  end
  
  def mattr_writer(*syms)
    options = syms.last.is_a?(Hash) ? syms.pop : {}
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}                       # unless defined? @@pagination_options
          @@#{sym} = nil                               #   @@pagination_options = nil
        end                                            # end
                                                       #
        def self.#{sym}=(obj)                          # def self.pagination_options=(obj)
          @@#{sym} = obj                               #   @@pagination_options = obj
        end                                            # end
                                                       #
        #{"                                            #
        def #{sym}=(obj)                               # def pagination_options=(obj)
          @@#{sym} = obj                               #   @@pagination_options = obj
        end                                            # end
        " unless options[:instance_writer] == false }  # # instance writer above is generated unless options[:instance_writer] == false
      EOS
    end
  end
  
  def mattr_accessor(*syms)
    mattr_reader(*syms)
    mattr_writer(*syms)
  end
end
