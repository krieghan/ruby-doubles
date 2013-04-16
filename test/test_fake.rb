require 'rdouble/fake'
require 'test/unit'

class A
  def a
    return "instance method returns a"
  end

  def self.a
    return "class method returns a"
  end
end
              
def b(this)
  return "method returns b"
end


class FakeTest < Test::Unit::TestCase
  def test_install_fake_for_all_instances
    a1 = A.new()
    RDouble::Fake.swap(A, "a", method(:b), :all_instances => true)
    a2 = A.new() 
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("class method returns a", A.a())
    RDouble::Fake.unswap()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("class method returns a", A.a())
  end

  def test_install_fake_on_class
    a1 = A.new()
    RDouble::Fake.swap(A, "a", method(:b))
    a2 = A.new()
    assert_equal("method returns b", A.a())
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    RDouble::Fake.unswap()
    assert_equal("class method returns a", A.a())
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
  end

  def test_install_on_one_instance
    a1 = A.new()
    a2 = A.new() 
    RDouble::Fake.swap(a1, "a", method(:b))
    a3 = A.new()
    assert_equal("method returns b", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns a", a3.a())
    assert_equal("class method returns a", A.a())
    RDouble::Fake.unswap()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns a", a3.a())
    assert_equal("class method returns a", A.a())
  end

  def test_install_on_bool
    def fake_inspect(this)
      return (!this).to_s
    end
    RDouble::Fake.swap(true, "inspect", method(:fake_inspect))
    assert_equal("false", true.inspect)
    assert_equal("false", false.inspect)
    RDouble::Fake.unswap()
    assert_equal("true", true.inspect)
    assert_equal("false", false.inspect)
  end

  def test_abs_on_1
    def fake_abs(this)
      return -1 * this
    end
    RDouble::Fake.swap(1, "abs", method(:fake_abs))
    assert_equal(-1, 1.abs()) 
    assert_equal(-2, 2.abs())
    RDouble::Fake.unswap()
    assert_equal(1, 1.abs())
    assert_equal(2, 2.abs())
  end
end