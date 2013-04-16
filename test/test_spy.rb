require 'rdouble/fake'
require 'rdouble/spy'
require 'test-unit'

class A
  def self.a(arg)
    return "class method a"
  end

  def a(arg)
    return "instance method a"
  end
end


class StubTest < Test::Unit::TestCase
  def test_put_spy_on_class
    spy_a = RDouble::Spy.new(:returns => "method b")
    RDouble::Fake.swap(A,
                       "a",
                       spy_a)
    returned = A.a(1)
    assert_equal("method b", returned)
    assert_equal(1, spy_a.calls.size)
    assert_equal([1], spy_a.calls[0])
    RDouble::Fake.unswap()
    returned = A.a(1)
    assert_equal("class method a", returned)
    assert_equal(1, spy_a.calls.size)
  end

  def test_put_spy_on_instance
    spy_a = RDouble::Spy.new(:returns => "method b")
    a1 = A.new
    a2 = A.new
    RDouble::Fake.swap(a1,
                       "a",
                       spy_a)
    assert_equal("method b", a1.a(1))
    assert_equal("instance method a", a2.a(1))
    assert_equal(1, spy_a.calls.size)
    assert_equal([1], spy_a.calls[0])
    RDouble::Fake.unswap()
    returned = a1.a(1)
    assert_equal("instance method a", returned)
    assert_equal(1, spy_a.calls.size)
  end

  def test_put_spy_on_all_instances
    a1 = A.new
    a2 = A.new
    spy_a = RDouble::Spy.new(:returns => "method b")
    RDouble::Fake.swap(A,
                       "a",
                       spy_a,
                       :all_instances => true)
    returned_1 = a1.a(1)
    returned_2 = a2.a(2)
    assert_equal("method b", returned_1)
    assert_equal("method b", returned_2)
    assert_equal([[1], [2]], spy_a.calls)
    RDouble::Fake.unswap()
    assert_equal("instance method a", a1.a(3))
    assert_equal("instance method a", a2.a(4))
    assert_equal([[1], [2]], spy_a.calls)
  end
end
