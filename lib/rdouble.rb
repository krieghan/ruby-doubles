require 'rdouble/fake'
require 'rdouble/stub'
require 'rdouble/spy'

module RDouble
  def swap_double(subject, method_name, method, options={})
    RDouble::Fake.swap(subject, method_name, method, options)
  end

  def unswap_doubles(options={})
    subject = options[:subject]
    method_name = options[:method_name]
    if subject.nil? && method_name.nil?
      RDouble::Fake.unswap()
    elsif !subject.nil? && method_name.nil?
      RDouble::Fake.unswap_all_for_subject(subject)
    elsif !subject.nil? && !method_name.nil?
      RDouble::Fake.unswap_method_for_subject(subject, method_name)
    elsif subject.nil? && !method_name.nil?
      raise Exception.new("A method_name cannot be specifically unswapped without a subject")
    end
  end

  def create_stub(attributes)
    return RDouble::StubObject.new(attributes)
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

  def get_double(subject, method_name)
    RDouble::Fake.get_double(subject, method_name)
  end

  def teardown
    unswap_doubles
    super
  end
end
