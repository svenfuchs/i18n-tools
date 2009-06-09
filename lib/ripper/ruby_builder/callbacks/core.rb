class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Core
      def on_ident(token)
        Ruby::Identifier.new(token, position, pop_whitespace)
      end

      def on_kw(token)
        if %w(do end not and or).include?(token)
          return push(super) 
        else
          Ruby::Keyword.new(token, position, pop_whitespace)
        end
      end

      def on_int(token)
        Ruby::Integer.new(token, position, pop_whitespace)
      end

      def on_float(token)
        Ruby::Float.new(token, position, pop_whitespace)
      end

      def on_const(token)
        Ruby::Const.new(token, position, pop_whitespace)
      end

      def on_class(const, super_class, body)
        Ruby::Class.new(const, super_class, body)
      end

      def on_def(identifier, params, body)
        Ruby::Method.new(identifier.token, identifier.position, params, body)
      end

      def on_const_ref(const)
        const # not sure what to do here
      end

      def on_field(field)
        field # not sure what to do here
      end

      def on_var_ref(ref)
        ref # not sure what to do here
      end

      def on_var_field(field)
        field # not sure what to do here
      end
    end
  end
end