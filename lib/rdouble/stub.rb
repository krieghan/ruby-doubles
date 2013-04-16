
module RDouble
  class Stub
    def initialize(options={})
      defaults = {:returns => nil}
      @options = defaults.merge(options)
    end

    def call(this, *args)
      if @options.key?(:raises)
        raise @options[:raises]
      else
        return @options[:returns]
      end
    end
  end

  def stub(subject, method_name, stub_options, options)
    stub_to_swap_in = RDouble::Stub.new(stub_options)
    RDouble::Fake.swap(subject,
                       method_name,
                       stub_to_swap_in,
                       options)
  end
end
