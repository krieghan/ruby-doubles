require 'rdouble/fake'
require 'rdouble/stub'
require 'rdouble/spy'

module RDouble
  def self.swap_double(subject, method_name, method, options={})
    defaults = {:namespace => :standard}
    options = defaults.merge(options)
    RDouble::Fake.swap(subject, method_name, method, options)
  end

  def self.add_function(subject, method_name, method, options={})
    defaults = {:namespace => :standard}
    options = defaults.merge(options)
    RDouble::Fake.add(subject, method_name, method, options)
  end

  def add_function(*args)
    RDouble::add_function(*args)
  end

  def swap_double(*args)
    RDouble::swap_double(*args)
  end

  def self.unswap_doubles(options={})
    defaults = {:namespace => :standard}
    options = defaults.merge(options)
    subject = options[:subject]
    method_name = options[:method_name]
    if subject.nil? && method_name.nil?
      RDouble::Fake.unswap(options)
    elsif !subject.nil? && method_name.nil?
      RDouble::Fake.unswap_all_for_subject(subject, options)
    elsif !subject.nil? && !method_name.nil?
      RDouble::Fake.unswap_method_for_subject(subject, method_name, options)
    elsif subject.nil? && !method_name.nil?
      raise Exception.new("A method_name cannot be specifically unswapped without a subject")
    end
  end

  def unswap_doubles(*args)
    RDouble::unswap_doubles(*args)
  end

  def self.create_stub(attributes={})
    return RDouble::StubObject.new(attributes)
  end

  def create_stub(*args)
    RDouble::create_stub(*args)
  end

  def self.install_stub(subject, method_name, options={})
    swap_options = {}
    swap_options[:all_instances] = (options.delete(:all_instances) || false)
    swap_options[:namespace] = (options.delete(:namespace) || :standard)
    stub_function = Stub.new(options)
    swap_double(subject, method_name, stub_function, swap_options)
    return stub_function
  end

  def install_stub(*args)
    RDouble::install_stub(*args)
  end

  def self.install_spy(subject, method_name, options={})
    swap_options = {}
    swap_options[:all_instances] = (options.delete(:all_instances) || false)
    swap_options[:namespace] = (options.delete(:namespace) || :standard)
    spy_function = Spy.new(options)
    swap_double(subject, method_name, spy_function, swap_options)
    return spy_function
  end

  def install_spy(*args)
    RDouble::install_spy(*args)
  end

  def self.install_decorator(subject, method_name, decorator_function, options={})
    swap_double(subject, method_name, decorator_function, options)
  end

  def install_decorator(*args)
    RDouble::install_decorator(*args)
  end

  def self.get_double(subject, method_name)
    RDouble::Fake.get_double(subject, method_name)
  end

  def get_double(*args)
    RDouble::get_double(*args)
  end

  def teardown
    unswap_doubles(:namespace => :standard)
    super
  end
end
