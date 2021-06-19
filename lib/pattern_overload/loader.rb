# frozen_string_literal: true

module PatternOverload
  class Loader
    def initialize(klass)
      @klass = klass
      @builders = {}
    end

    def add(name, pattern, kw_pattern, block_pattern, if_pattern, unless_pattern)
      builder = @builders.fetch(name) do
        @builders[name] = PatternOverload::Builder.new(name)
      end
      new_name = builder.add(pattern, kw_pattern, block_pattern, if_pattern, unless_pattern)
      @klass.alias_method(new_name, name)

      if standard_method_name?(name)
        src = "def #{name}(*args, **kw, &block); #{builder.body}; end"
        @klass.class_eval(src)
      else
        @klass.class_eval do
          define_method(name, eval("proc |*args, **kw, &block| #{builder.body}; end"))
        end
      end
    end

    def standard_method_name?(n)
      name = n.to_s
      case name
      when "|", "^", "&", "<=>", "==", "===", "=~", ">", ">=", "<", "<=", "<<", ">>", "+", "-", "*", "/", "%", "**", "~", "+@", "-@", "[]", "[]=", "`", "!", "!=", "!~"
        true
      else
        name.match?(/\A[_A-Za-z]\w*\z/)
      end
    end
  end
end
