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
end
