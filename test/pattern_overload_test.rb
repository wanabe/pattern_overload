# frozen_string_literal: true

require "test_helper"

class PatternOverloadTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::PatternOverload.const_defined?(:VERSION)
    end
  end

  test "standard method overloading" do
    klass = Class.new do
      include PatternOverload::DSL

      overload String, to:
      def foo(x)
        :str
      end

      overload String, String, to:
      def foo(x, y)
        :str2
      end

      overload Integer, to:
      def foo(x)
        :int
      end

      overload "*", kw: "foo:", to:
      def foo(foo:)
        :kw_foo
      end

      overload block: "b", if: "b && b.arity == 1", to:
      def foo(&b)
        :block_arity1
      end

      overload block: true, to:
      def foo(&b)
        :block
      end

      overload to:
      def foo
        :noarg
      end
    end

    obj = klass.new
    assert_equal(:str, obj.foo("foo"))
    assert_equal(:str2, obj.foo("foo", "bar"))
    assert_equal(:int, obj.foo(0))
    assert_equal(:noarg, obj.foo)
    assert_equal(:kw_foo, obj.foo(foo: :bar))
    assert_equal(:block_arity1, obj.foo{|a|})
    assert_equal(:block, obj.foo{})
    assert_equal(:noarg, obj.foo)
  end
end
