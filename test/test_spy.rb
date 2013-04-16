require 'rdouble'
require 'test-unit'

class SpyTest < Test::Unit::TestCase
  include RDouble
  class A
    def self.a(arg)
      return "class method a"
    end

    def a(arg)
      return "instance method a"
    end
  end

  def test_put_spy_on_class
    spy_a = RDouble::Spy.new(:returns => "method b")
    swap_double(A, "a", spy_a)
    returned = A.a(1)
    assert_equal("method b", returned)
    assert_equal(1, spy_a.calls.size)
    assert_equal([1], spy_a.calls[0])
    unswap_doubles()
    returned = A.a(1)
    assert_equal("class method a", returned)
    assert_equal(1, spy_a.calls.size)
  end

  def test_put_spy_on_instance
    spy_a = RDouble::Spy.new(:returns => "method b")
    a1 = A.new
    a2 = A.new
    swap_double(a1, "a", spy_a)
    assert_equal("method b", a1.a(1))
    assert_equal("instance method a", a2.a(1))
    assert_equal(1, spy_a.calls.size)
    assert_equal([1], spy_a.calls[0])
    unswap_doubles()
    returned = a1.a(1)
    assert_equal("instance method a", returned)
    assert_equal(1, spy_a.calls.size)
  end

  def test_put_spy_on_all_instances
    a1 = A.new
    a2 = A.new
    spy_a = RDouble::Spy.new(:returns => "method b")
    swap_double(A, "a", spy_a, :all_instances => true)
    returned_1 = a1.a(1)
    returned_2 = a2.a(2)
    assert_equal("method b", returned_1)
    assert_equal("method b", returned_2)
    assert_equal([[1], [2]], spy_a.calls)
    unswap_doubles()
    assert_equal("instance method a", a1.a(3))
    assert_equal("instance method a", a2.a(4))
    assert_equal([[1], [2]], spy_a.calls)
  end

  def test_install_spy_on_instance
    a1 = A.new()
    spy_a = install_spy(a1, "a", :returns => "method b")
    assert_equal("method b", a1.a(1))
    assert_equal([[1]], spy_a.calls)
  end

  def test_get_spy
    a1 = A.new()
    install_spy(a1, "a", :returns => "method b")
    assert_equal("method b", a1.a(1))
    spy_a = get_double(a1, "a")
    assert_equal([[1]], spy_a.calls)
  end
end
