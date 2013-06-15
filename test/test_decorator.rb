require 'rdouble'
require 'ruby-debug'
require 'test/unit'

class A
  def normal_instance_function
    return "normal_instance_function"
  end

  def self.normal_class_function
    return "normal_class_function"
  end
end

def decorator(context)
  normal_function = context[:original_method]
  return "decorated #{normal_function.call}"
end

def redecorator(context)
  normal_function = context[:original_method]
  return "redecorated #{normal_function.call}"
end

def reredecorator(context)
  normal_function = context[:original_method]
  return "reredecorated #{normal_function.call}"
end

class DecoratorTest < Test::Unit::TestCase
  include RDouble

  def test_install_decorator_on_all_instances
    RDouble.install_decorator(A, 
                              :normal_instance_function, 
                              method(:decorator), 
                              :all_instances => true)
    a = A.new                              
    assert_equal("decorated normal_instance_function", a.normal_instance_function)
    RDouble.unswap_doubles()
    assert_equal("normal_instance_function", a.normal_instance_function)
  end

  def test_install_decorator_on_class
    RDouble.install_decorator(A, :normal_class_function, method(:decorator))
    assert_equal("decorated normal_class_function", A.normal_class_function)
    RDouble.unswap_doubles()
    assert_equal("normal_class_function", A.normal_class_function)
  end

  def test_install_decorator_on_instance
    a = A.new
    RDouble.install_decorator(a, :normal_instance_function, method(:decorator))
    assert_equal("decorated normal_instance_function", a.normal_instance_function)
    RDouble.unswap_doubles()
    assert_equal("normal_instance_function", a.normal_instance_function)
  end

  def test_install_decorator_chain
    a = A.new
    RDouble.install_decorator(a, :normal_instance_function, method(:decorator))
    RDouble.install_decorator(a, :normal_instance_function, method(:redecorator))
    RDouble.install_decorator(a, :normal_instance_function, method(:reredecorator))
    assert_equal("reredecorated redecorated decorated normal_instance_function", 
                 a.normal_instance_function)
    RDouble.unswap_doubles()
    assert_equal("normal_instance_function", a.normal_instance_function)
  end
end


