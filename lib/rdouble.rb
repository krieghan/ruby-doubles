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

  def teardown
    unswap_doubles
    super
  end
end
