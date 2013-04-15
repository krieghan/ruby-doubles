require 'ruby-debug'

module RDouble
  def self.install_fake_on_class(klass, method_name, method)
    klass.module_eval do
      define_singleton_method("rdouble_old_#{method_name}", method(method_name))
      define_singleton_method method_name do |*args|
         method.call(self) 
      end
    end
  end

  def self.install_fake_on_instances(klass, method_name, method)
    klass.module_eval do
      class_eval("alias rdouble_old_#{method_name} #{method_name}")

      define_method method_name do |*args|
         method.call(self) 
      end
    end
  end

  def self.install_fake_on_instance(instance, method_name, method)
    instance.instance_eval do
      define_singleton_method("rdouble_old_#{method_name}", method(method_name))
      define_singleton_method method_name do |*args|
        method.call(self)
      end
    end
  end

  def self.uninstall_fake_on_class(klass, method_name)
    klass.module_eval do
      define_singleton_method(method_name, method("rdouble_old_#{method_name}"))
    end
  end

  def self.uninstall_fake_on_instances(klass, method_name)
    klass.module_eval do
      class_eval("alias #{method_name} rdouble_old_#{method_name}")
    end
  end

  def self.uninstall_fake_on_instance(instance, method_name)
    instance.instance_eval do
      define_singleton_method(method_name, method("rdouble_old_#{method_name}"))
    end
  end

  def self.install_fake(klass, method_name, method, type=:self)
    if klass.class == Class 
      if type == :self
        install_fake_on_class(klass, method_name, method)
      elsif type == :instances
        install_fake_on_instances(klass, method_name, method)
      end
    else
      if klass.kind_of?(Numeric)
        install_fake_on_instances(klass.class, method_name, method)  
      else
        install_fake_on_instance(klass, method_name, method)
      end
    end
  end

  def self.uninstall_fake(klass, method_name, type=:self)
    if klass.class == Class
      if type == :self
        uninstall_fake_on_class(klass, method_name)
      elsif type == :instances
        uninstall_fake_on_instances(klass, method_name)
      end
    else
      if klass.kind_of?(Numeric)
        uninstall_fake_on_instances(klass.class, method_name)  
      else
        uninstall_fake_on_instance(klass, method_name)
      end
    end
  end
end
