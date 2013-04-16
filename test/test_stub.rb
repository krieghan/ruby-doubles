require 'rdouble'
require 'test-unit'

class StubTest < Test::Unit::TestCase
  include RDouble
  class A
    def self.a
      return "class method a"
    end

    def a
      return "instance method a"
    end
  end

  def test_stub_on_class
    swap_double(A, "a", Stub.new(:returns => "method b"))
    assert_equal("method b", A.a())
    unswap_doubles()
    assert_equal("class method a", A.a())
  end

  def test_stub_on_instance
    a = A.new()
    swap_double(a, "a", Stub.new(:returns => "method b"))
    assert_equal("method b", a.a())
    unswap_doubles()
    assert_equal("instance method a", a.a())
  end

  def test_stub_on_all_instances
    swap_double(A, "a", Stub.new(:returns => "method b"), :all_instances => true)
    a = A.new()
    assert_equal("method b", a.a())
    unswap_doubles()
    assert_equal("instance method a", a.a())
  end

  def test_stub_exception_on_instance
    a = A.new()
    swap_double(a, "a", Stub.new(:raises => Exception.new()))
    assert_raises(Exception) do 
      a.a()
    end
    unswap_doubles()
  end

  def test_stub_exception_class_on_instance
    a = A.new()
    swap_double(a, "a", Stub.new(:raises => Exception))
    assert_raises(Exception) do
      a.a()
    end
    unswap_doubles()
  end

end
