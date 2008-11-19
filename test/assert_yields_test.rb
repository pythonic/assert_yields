# Copyright (c) 2007, 2008 Pythonic Pty Ltd
# http://www.pythonic.com.au/

require "test/unit"
require File.dirname(__FILE__) + "/../init.rb"

class Integer
  # Yields to block with values from zero to self - 1, and returns self.
  def times
    k = 0
    while k < self
      yield k
      k += 1
    end
    return self
  end
end

class TestAssertYields < Test::Unit::TestCase
  # These tests assume Integer#times is implemented correctly.

  def yield_then_raise
    yield
    raise
  end

  def test_yields
    assert_equal [0, 1, 2], 3.method(:times).yields
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

  def test_assertion_failed
    assert_raises Test::Unit::AssertionFailedError do
      assert_method_yields 1.method(:times) do |p|
        assert_equal 1, p.call
      end
    end
  end

  def test_method_first_exception
    assert_raises RuntimeError do
      assert_method_yields method(:raise) do |p|
      end
    end
  end

  def test_method_second_exception
    assert_raises RuntimeError do
      assert_method_yields method(:yield_then_raise) do |p|
        p.call
      end
    end
  end

  def test_block_first_exception
    assert_raises RuntimeError do
      assert_method_yields 0.method(:times) do |p|
        raise
      end
    end
  end

  def test_block_second_exception
    assert_raises RuntimeError do
      assert_method_yields 1.method(:times) do |p|
        p.call
        raise
      end
    end
  end

  def test_error_precedence
    assert_raises Test::Unit::AssertionFailedError do
      assert_method_yields method(:raise) do |p|
        assert_equal 0, 1
      end
    end
  end

  def test_synchronized
    assert_raises Test::Unit::AssertionFailedError do
      assert_method_yields method(:yield_then_raise) do |p|
      end
    end
  end

  def test_inject
    result = assert_method_yields [1, 2, 3].method(:inject), 0 do |p|
      assert_equal [0, 1], p.call(&:+)
      assert_equal [1, 2], p.call(&:+)
      assert_equal [3, 3], p.call(&:+)
    end
    assert_equal 6, result
  end
end
