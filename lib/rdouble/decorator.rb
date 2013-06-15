class RDouble::Decorator
  def initialize(decorator_function, decorated_function, options={})
    @decorator_function = decorator_function
    @decorated_function = decorated_function
    @options = options
  end

  def call(this, *args)
    return @decorator_function.call(@decorated_function)
  end
end
