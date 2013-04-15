module RDouble
  def self.install_fake(klass, method_name, method)
    klass.module_eval do
      class_eval("alias rdouble_old_#{method_name} #{method_name}")

      define_method method_name do |*args|
         method.call() 
      end
    end
  end

  def self.uninstall_fake(klass, method_name)
    klass.module_eval do
      class_eval("alias #{method_name} rdouble_old_#{method_name}")
    end
  end
end
