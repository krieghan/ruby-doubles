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

  def test_install_stub_on_instance
    a = A.new()
    install_stub(a, "a", :returns => "method b")
    assert_equal("method b", a.a())
    unswap_doubles()
    assert_equal("instance method a", a.a())
  end

  def test_install_stub_on_all_instances
    a = A.new()
    install_stub(A, "a", :returns => "method b", :all_instances => true)
    assert_equal("method b", a.a()) 
    unswap_doubles()
    assert_equal("instance method a", a.a())
  end
end

class StubObjectTest < Test::Unit::TestCase
  include RDouble

  def test_create_stub_object
    a1 = StubObject.new({:a => 1, :b => 2})
    a2 = StubObject.new({:b => 3, :c => 4})
    assert_equal(1, a1.a)
    assert_equal(2, a1.b)
    assert_equal(3, a2.b)
    assert_equal(4, a2.c)
    assert_raises(NoMethodError) {a1.c}
    assert_raises(NoMethodError) {a2.a}
  end

  def test_create_stub_public
    a1 = create_stub({:a => 1, :b => 2})
    a2 = create_stub({:b => 3, :c => 4})
    assert_equal(1, a1.a)
    assert_equal(2, a1.b)
    assert_equal(3, a2.b)
    assert_equal(4, a2.c)
    assert_raises(NoMethodError) {a1.c}
    assert_raises(NoMethodError) {a2.a}
  end
end
