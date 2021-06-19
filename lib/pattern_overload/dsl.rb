# frozen_string_literal: true

module PatternOverload
  module DSL
    class << self
      def included(klass)
        klass.extend(PatternOverload::DSL::ClassMethods)
      end
    end

    module ClassMethods
      def overload(*pattern_ary, kw: nil, block: nil, to:, **opts)
        @__pattern_overload_loader ||= PatternOverload::Loader.new(self)
        case block
        when true
          block_pattern = "Proc"
        when false
          block_pattern = "nil"
        when nil
          block_pattern = "Proc | nil"
        else
          block_pattern = block.to_s
        end
        if_pattern = opts[:if]&.to_s
        unless_pattern = opts[:unless]&.to_s
        @__pattern_overload_loader.add(to, pattern_ary.map(&:to_s).join(", "), kw&.to_s || "", block_pattern, if_pattern, unless_pattern)
      end
    end

    def __pattern_overload_method_missing(name, args, kw, block)
      raise NameError.new("undefined overloaded method `#{name}' with (#{args.map(&:inspect).join(", ")})", name, receiver: self)
    end
  end
end
