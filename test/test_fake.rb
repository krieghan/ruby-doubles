require 'rdouble'
require 'test/unit'

class FakeTest < Test::Unit::TestCase
  include RDouble

  class A
    def a
      return "instance method returns a"
    end

    def b
      return "instance method returns b"
    end

    def self.a
      return "class method returns a"
    end

    def self.b
      return "class method returns b"
    end
  end

  class B < A
    def a
      return "subclass instance method returns a"
    end

    def self.a
      return "subclass class method returns a"
    end
  end
                
  def b(this)
    return "method returns b"
  end

  def test_install_fake_for_all_instances
    a1 = A.new()
    swap_double(A, "a", method(:b), :all_instances => true)
    a2 = A.new() 
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("class method returns a", A.a())
    unswap_doubles()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("class method returns a", A.a())
  end

  def test_install_fake_on_class
    a1 = A.new()
    swap_double(A, "a", method(:b))
    a2 = A.new()
    assert_equal("method returns b", A.a())
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    unswap_doubles()
    assert_equal("class method returns a", A.a())
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
  end

  def test_install_on_one_instance
    a1 = A.new()
    a2 = A.new() 
    swap_double(a1, "a", method(:b))
    a3 = A.new()
    assert_equal("method returns b", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns a", a3.a())
    assert_equal("class method returns a", A.a())
    unswap_doubles()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns a", a3.a())
    assert_equal("class method returns a", A.a())
  end

  def test_install_on_bool
    def fake_inspect(this)
      return (!this).to_s
    end
    swap_double(true, "inspect", method(:fake_inspect))
    assert_equal("false", true.inspect)
    assert_equal("false", false.inspect)
    unswap_doubles()
    assert_equal("true", true.inspect)
    assert_equal("false", false.inspect)
  end

  def test_abs_on_1
    def fake_abs(this)
      return -1 * this
    end
    swap_double(1, "abs", method(:fake_abs))
    assert_equal(-1, 1.abs()) 
    assert_equal(-2, 2.abs())
    unswap_doubles()
    assert_equal(1, 1.abs())
    assert_equal(2, 2.abs())
  end

  def test_unswap_all
    a1 = A.new()
    a2 = A.new()
    swap_double(a1, "a", method(:b))
    swap_double(a1, "b", method(:b))
    swap_double(a2, "a", method(:b))
    swap_double(a2, "b", method(:b))
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
    unswap_doubles()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns b", a1.b())
    assert_equal("instance method returns b", a2.b())
  end

  def test_unswap_for_subject
    a1 = A.new()
    a2 = A.new()
    swap_double(a1, "a", method(:b))
    swap_double(a1, "b", method(:b))
    swap_double(a2, "a", method(:b))
    swap_double(a2, "b", method(:b))
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
    unswap_doubles(:subject => a1)
    assert_equal("instance method returns a", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("instance method returns b", a1.b())
    assert_equal("method returns b", a2.b())
  end

  def test_unswap_method
    a1 = A.new()
    a2 = A.new()
    swap_double(a1, "a", method(:b))
    swap_double(a1, "b", method(:b))
    swap_double(a2, "a", method(:b))
    swap_double(a2, "b", method(:b))
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
    unswap_doubles(:subject => a1, :method_name => "a")
    assert_equal("instance method returns a", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
  end

  def test_swap_overridden_class_method
    swap_double(A, "a", method(:b))
    assert_equal("method returns b", A.a())
    assert_equal("subclass class method returns a", B.a())
    unswap_doubles()
    assert_equal("class method returns a", A.a())
    assert_equal("subclass class method returns a", B.a())
  end

  def test_swap_inherited_class_method
    swap_double(A, "b", method(:b))
    assert_equal("method returns b", A.b())
    assert_equal("method returns b", B.b())
    unswap_doubles()
    assert_equal("class method returns b", A.b())
    assert_equal("class method returns b", B.b())
  end
end
