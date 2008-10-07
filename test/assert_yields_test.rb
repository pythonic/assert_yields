# Copyright (c) 2007, 2008 Pythonic Pty. Ltd. http://www.pythonic.com.au/

require "test/unit"
require File.dirname(__FILE__) + "/../init.rb"

class Integer
  # Iterates block int times, passing in values from zero to int - 1.
  def times
    k = 0
    while k < self
      yield k
      k += 1
    end
  end
end

class TestAssertYields < Test::Unit::TestCase
  # These tests assume Integer#times is implemented correctly.

  def test_yields
    assert_equal [0, 1], 2.method(:times).yields
  end

  def test_zero_yields
    assert_method_yields 0.method(:times)
  end

  def test_one_yield
    assert_method_yields 1.method(:times) do |p|
      assert_equal 0, p.call
    end
  end

  def test_two_yields
    assert_method_yields 2.method(:times) do |p|
      assert_equal 0, p.call
      assert_equal 1, p.call
    end
  end

  def test_yield_missing
    assert_raises Test::Unit::AssertionFailedError do
      assert_method_yields 0.method(:times) do |p|
        p.call
      end
    end
  end

  def test_unexpected_yield
    assert_raises Test::Unit::AssertionFailedError do
      assert_method_yields 2.method(:times) do |p|
        p.call
      end
    end
  end
end
