require 'rdouble/stub'

module RDouble
  class Spy < RDouble::Stub
    def initialize(options={})
      @calls = []
      super(options)
    end

    def call(this, *args)
      @calls.push(args)
      return super(this, *args)
    end

    def calls
      return @calls
    end
  end
end
