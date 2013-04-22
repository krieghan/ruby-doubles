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

  class StubObject
    def initialize(attributes={})
      attributes.each do |key, value|
        RDouble::Fake.define_singleton_method_for_subject(self, key, :instance) do |*args|
          return value      
        end
      end
    end
  end
end
