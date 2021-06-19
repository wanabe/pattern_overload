# frozen_string_literal: true

module PatternOverload
  class Builder
    def initialize(name)
      @name = name.to_s
      @body = +""
    end

    def body
      "case [args, kw, block]; #{@body}; else __pattern_overload_method_missing(#{@name.dump}, args, kw, block); end"
    end

    def add(args_pattern, kw_pattern, block_pattern, if_pattern, unless_pattern)
      new_name = +"__pattern_overloaded_"
      new_name << normalize(@name)
      new_name << "_"
      new_name << normalize(args_pattern)
      new_name << "_"
      new_name << normalize(kw_pattern)
      new_name << "_"
      new_name << normalize(block_pattern)
      new_name << "_if_"
      if if_pattern
        new_name << normalize(if_pattern)
      else
        new_name << "nocond"
      end
      new_name << "_unless_"
      if unless_pattern
        new_name << normalize(unless_pattern)
      else
        new_name << "nocond"
      end

      @body << "in [[#{args_pattern}], {#{kw_pattern}}, #{block_pattern}] "
      if if_pattern
        @body << "if #{if_pattern} "
      end
      if unless_pattern
        @body << "unless #{unless_pattern} "
      end
      @body << "; #{new_name}(*args, **kw); "
      new_name
    end

    def normalize(name)
      name.gsub(/[^0-9A-Za-z]/) { |c| "_#{c.ord.to_s(16)}_" }
    end
  end
end
