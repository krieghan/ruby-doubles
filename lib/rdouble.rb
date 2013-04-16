require 'rdouble/fake'
require 'rdouble/stub'
require 'rdouble/spy'

module RDouble
  def swap_double(subject, method_name, method, options={})
    RDouble::Fake.swap(subject, method_name, method, options)
  end

  def unswap_doubles
    RDouble::Fake.unswap()
  end

  def install_stub(subject, method_name, options={})
    swap_options = {}
    swap_options[:all_instances] = (options.delete(:all_instances) || false)
    stub_function = Stub.new(options)
    swap_double(subject, method_name, stub_function, swap_options)
    return stub_function
  end

  def install_spy(subject, method_name, options={})
    swap_options = {}
    swap_options[:all_instances] = (options.delete(:all_instances) || false)
    spy_function = Spy.new(options)
    swap_double(subject, method_name, spy_function, swap_options)
    return spy_function
  end

  def teardown
    unswap_doubles
    super
  end
end
