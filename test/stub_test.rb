require './stub'
require './fake'
require 'test-unit'
require 'ruby-debug'

class A
  def self.a
    return "class method a"
  end

  def a
    return "instance method a"
  end
end

class StubTest < Test::Unit::TestCase
  def test_stub_on_class
    RDouble::Fake.swap(A, 
                       "a", 
                       RDouble::Stub.new(:returns => "method b"))
    assert_equal("method b", A.a())
    RDouble::Fake.unswap()
    assert_equal("class method a", A.a())
  end

  def test_stub_on_instance
    a = A.new()
    RDouble::Fake.swap(a,
                       "a",
                       RDouble::Stub.new(:returns => "method b"))
    assert_equal("method b", a.a())
    RDouble::Fake.unswap()
    assert_equal("instance method a", a.a())
  end

  def test_stub_on_all_instances
    RDouble::Fake.swap(A,
                       "a",
                       RDouble::Stub.new(:returns => "method b"),
                       :all_instances => true)
    a = A.new()
    assert_equal("method b", a.a())
    RDouble::Fake.unswap()
    assert_equal("instance method a", a.a())
  end

  def test_stub_exception_on_instance
    a = A.new()
    RDouble::Fake.swap(a,
                       "a",
                       RDouble::Stub.new(:raises => Exception.new()))
    assert_raises(Exception) do 
      a.a()
    end
  end

  def test_stub_exception_class_on_instance
    a = A.new()
    RDouble::Fake.swap(a,
                       "a",
                       RDouble::Stub.new(:raises => Exception))
    assert_raises(Exception) do
      a.a()
    end
  end

end
