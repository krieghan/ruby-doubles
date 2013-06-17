require 'rdouble'
require 'ruby-debug'
require 'test/unit'

module C
  def a
    return "module instance method returns a"
  end

  def self.b
    return "module method returns b"
  end
end

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

    def self.this
      return self.to_s
    end

    private
    def private_a
      return "private instance method returns a"
    end

    def self.private_a
      return "private class method returns a"
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

  class D
    include C
  end

  class E
    include C
  end
                
  def b(context)
    this = context[:this]
    return "method returns b"
  end

  def fake_this(context)
    this = context[:this]
    return "Fake #{this.to_s}"
  end

  def teardown
    unswap_doubles()
  end

  def test_install_fake_for_all_instances
    a1 = A.new()
    RDouble::swap_double(A, "a", method(:b), :all_instances => true)
    a2 = A.new() 
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("class method returns a", A.a())
    RDouble::unswap_doubles()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("class method returns a", A.a())
  end

  def test_install_fake_on_class
    a1 = A.new()
    RDouble::swap_double(A, "a", method(:b))
    a2 = A.new()
    assert_equal("method returns b", A.a())
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    RDouble::unswap_doubles()
    assert_equal("class method returns a", A.a())
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
  end

  def test_install_on_one_instance
    a1 = A.new()
    a2 = A.new() 
    RDouble::swap_double(a1, "a", method(:b))
    a3 = A.new()
    assert_equal("method returns b", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns a", a3.a())
    assert_equal("class method returns a", A.a())
    RDouble::unswap_doubles()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns a", a3.a())
    assert_equal("class method returns a", A.a())
  end

  def test_private_method_on_instance
    a = A.new()
    RDouble::swap_double(a, "private_a", method(:b))
    assert_equal("method returns b", a.private_a)
  end

  def test_install_mixed_in_method_on_module
    RDouble::swap_double(C, "a", method(:b), :all_instances => true)
    d = D.new()
    assert_equal("method returns b", d.a())
    RDouble::unswap_doubles()
    assert_equal("module instance method returns a", d.a())
  end

  def test_install_on_module
    RDouble::swap_double(C, "b", method(:b))
    assert_equal("method returns b", C.b())
    RDouble::unswap_doubles()
    assert_equal("module method returns b", C.b())
  end

  def test_swap_mixed_in_method
    d = D.new()
    e = E.new()
    RDouble::swap_double(D, "a", method(:b), :all_instances => true)
    assert_equal("method returns b", d.a())
    assert_equal("module instance method returns a", e.a())
    RDouble::unswap_doubles()
    assert_equal("module instance method returns a", d.a())
    assert_equal("module instance method returns a", e.a())
  end

  def test_install_on_bool
    def fake_inspect(context)
      this = context[:this]
      return (!this).to_s
    end
    RDouble::swap_double(true, "inspect", method(:fake_inspect))
    assert_equal("false", true.inspect)
    assert_equal("false", false.inspect)
    RDouble::unswap_doubles()
    assert_equal("true", true.inspect)
    assert_equal("false", false.inspect)
  end

  def test_abs_on_1
    def fake_abs(context)
      this = context[:this]
      return -1 * this
    end
    RDouble::swap_double(1, "abs", method(:fake_abs))
    assert_equal(-1, 1.abs()) 
    assert_equal(-2, 2.abs())
    RDouble::unswap_doubles()
    assert_equal(1, 1.abs())
    assert_equal(2, 2.abs())
  end

  def test_unswap_all
    a1 = A.new()
    a2 = A.new()
    RDouble::swap_double(a1, "a", method(:b))
    RDouble::swap_double(a1, "b", method(:b))
    RDouble::swap_double(a2, "a", method(:b))
    RDouble::swap_double(a2, "b", method(:b))
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
    RDouble::unswap_doubles()
    assert_equal("instance method returns a", a1.a())
    assert_equal("instance method returns a", a2.a())
    assert_equal("instance method returns b", a1.b())
    assert_equal("instance method returns b", a2.b())
  end

  def test_unswap_for_subject
    a1 = A.new()
    a2 = A.new()
    RDouble::swap_double(a1, "a", method(:b))
    RDouble::swap_double(a1, "b", method(:b))
    RDouble::swap_double(a2, "a", method(:b))
    RDouble::swap_double(a2, "b", method(:b))
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
    RDouble::unswap_doubles(:subject => a1)
    assert_equal("instance method returns a", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("instance method returns b", a1.b())
    assert_equal("method returns b", a2.b())
  end

  def test_unswap_method
    a1 = A.new()
    a2 = A.new()
    RDouble::swap_double(a1, "a", method(:b))
    RDouble::swap_double(a1, "b", method(:b))
    RDouble::swap_double(a2, "a", method(:b))
    RDouble::swap_double(a2, "b", method(:b))
    assert_equal("method returns b", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
    RDouble::unswap_doubles(:subject => a1, :method_name => "a")
    assert_equal("instance method returns a", a1.a())
    assert_equal("method returns b", a2.a())
    assert_equal("method returns b", a1.b())
    assert_equal("method returns b", a2.b())
  end

  def test_swap_overridden_class_method
    RDouble::swap_double(A, "a", method(:b))
    assert_equal("method returns b", A.a())
    assert_equal("subclass class method returns a", B.a())
    RDouble::unswap_doubles()
    assert_equal("class method returns a", A.a())
    assert_equal("subclass class method returns a", B.a())
  end

  def test_swap_inherited_class_method
    assert_equal("class method returns b", A.b())
    assert_equal("class method returns b", B.b())
    RDouble::swap_double(A, "b", method(:b))
    assert_equal("method returns b", A.b())
    assert_equal("method returns b", B.b())
    RDouble::unswap_doubles()
    assert_equal("class method returns b", A.b())
    #This will throw a TypeError with Ruby 1.8.7
    assert_equal("class method returns b", B.b())
  end

  def test_swap_inherited_instance_method_all_instances
    RDouble::swap_double(A, "b", method(:b), :all_instances => true)
    b = B.new
    assert_equal("method returns b", b.b())
    RDouble::unswap_doubles()
    assert_equal("instance method returns b", b.b())
  end

  def test_swap_inherited_instance_method
    b = B.new
    RDouble::swap_double(b, "b", method(:b))
    assert_equal("method returns b", b.b())
    RDouble::unswap_doubles()
    assert_equal("instance method returns b", b.b())
  end

  def test_inherited_self
    assert_equal("FakeTest::A", A.this)
    assert_equal("FakeTest::B", B.this)
    RDouble::swap_double(A, "this", method(:fake_this))
    assert_equal("Fake FakeTest::A", A.this)
    assert_equal("Fake FakeTest::B", B.this)
    RDouble::unswap_doubles()
    assert_equal("FakeTest::A", A.this)
    assert_equal("FakeTest::B", B.this)
  end

  def test_swap_on_namespace
    RDouble::swap_double(A, "b", method(:b), :namespace => :global)
    assert_equal("method returns b", A.b())
    RDouble::unswap_doubles()
    assert_equal("method returns b", A.b())
    RDouble::unswap_doubles(:namespace => :global)
    assert_equal("class method returns b", A.b())
  end

  def test_cannot_swap_subject_across_namespaces
    RDouble::swap_double(A, "b", method(:b), :namespace => :standard)
    assert_raises(Exception) {RDouble::swap_double(A, "a", method(:b), :namespace => :global)}
    RDouble::unswap_doubles(:namespace => :standard)
    RDouble::unswap_doubles(:namespace => :global)
  end

  def test_subtree_swap_is_cleaned_up
    assert_equal(["a"], B.methods(false).map {|m| m.to_s})
    assert_equal("class method returns b", B.b)
    RDouble::swap_double(A, "b", method(:b))
    RDouble::unswap_doubles()
    assert_equal(["a"], B.methods(false).map {|m| m.to_s})
    assert_equal("class method returns b", B.b)
  end

  def test_add_new_function_to_class
    RDouble::add_function(A, "new_function", method(:b))
    assert_equal("method returns b", A.new_function())
    RDouble::unswap_doubles()
    assert_raises(NoMethodError) {A.new_function()}
  end

  def test_add_new_function_to_instance
    a = A.new()
    RDouble::add_function(a, "new_function", method(:b))
    assert_equal("method returns b", a.new_function())
    RDouble::unswap_doubles()
    assert_raises(NoMethodError) {a.new_function()}
  end

  def test_add_new_function_to_all_instances
    RDouble::add_function(A, "new_function", method(:b), :all_instances => true)
    a = A.new()
    assert_equal("method returns b", a.new_function())
    RDouble::unswap_doubles()
    assert_raises(NoMethodError) {a.new_function()}
  end
end
