# Copyright (c) 2007, 2008 Pythonic Pty Ltd
# http://www.pythonic.com.au/

class Object
  def returning(value)
    yield(value)
    value
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class Method
  # Returns array of values yielded by method.
  # Example:
  #   3.method(:times).yields # => [0, 1, 2]
  def yields(*args)
    array = []
    call(*args, &array.method(:<<))
    array
  end
end

module Test
  module Unit
    module Assertions
      # Yields to block with proc argument to get each value yielded by given
      # method and raises assertion error unless method yields exact number of
      # values required by block.
      # Examples:
      #   assert_method_yields 2.method(:times) do |p|
      #     assert_equal 0, p.call
      #     assert_equal 1, p.call
      #   end
      #   assert_method_yields [1, 2, 3].method(:inject), 0 do |p|
      #     assert_equal [0, 1], p.call(&:+)
      #     assert_equal [1, 2], p.call(&:+)
      #     assert_equal [3, 3], p.call(&:+)
      #   end
      def assert_method_yields(method, *args)
        block_c, block_f = callcc do |method_c|
          p = lambda do |&block_f|
            method_c, values = callcc do |block_c|
              method_c.call(block_c, block_f)
            end
            return *values
          end
          yield p if block_given?
          method_c.call(nil, nil)
        end
        result = method.call(*args) do |*values|
          raise AssertionFailedError, "unexpected yield: #{values.map(&:inspect) * ", "}" unless block_c
          returning block_f && block_f.call(*values) do
            block_c, block_f = callcc do |method_c|
              block_c.call(method_c, values)
            end
          end
        end
        raise AssertionFailedError, "yield missing" if block_c
        result
      end
    end
  end
end
