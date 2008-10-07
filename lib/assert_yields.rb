# Copyright (c) 2007, 2008 Pythonic Pty. Ltd. http://www.pythonic.com.au/

class Continuation
  alias_method :jump, :call
end

class Method
  # Returns array of values yielded by method.
  # Example:
  #   2.method(:times).yields # => [0, 1]
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
      # times required by block.
      # Example:
      #   assert_method_yields 2.method(:times) do |p|
      #     assert_equal 0, p.call
      #     assert_equal 1, p.call
      #   end
      def assert_method_yields(m, *args)
        c1 = nil
        callcc do |c2|
          p2 = proc do
            c2, arg = callcc do |c1|
              c2.jump(c1)
            end
            arg
          end
          yield p2 if block_given?
          c2.jump
        end
        p1 = lambda do |arg|
          c1 = callcc do |c2|
            raise AssertionFailedError, "unexpected yield: #{arg.inspect}" unless c1
            c1.jump(c2, arg)
          end
        end
        m.call(*args, &p1)
        raise AssertionFailedError, "yield missing" if c1
      end
    end
  end
end
