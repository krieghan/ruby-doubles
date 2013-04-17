require 'rdouble/stub'

module RDouble
  class Spy < RDouble::Stub
    def initialize(options={})
      @calls = []
      super(options)
    end

    def call(this, *args)
      c = Call.new(args)
      @calls.push(c)
      return super(this, *args)
    end

    def calls
      return @calls
    end
  end

  class Call
    def initialize(arguments)
      @arguments = arguments 
    end

    def arguments
      return @arguments
    end
  end
end
