module RDouble
  class Fake
    @@originals = {}
    @@current_methods = {}

    public
    def self.swap(klass, method_name, method, options={})
      defaults = {:all_instances => false}
      options = defaults.merge(options)
      if klass.class == Class 
        if options[:all_instances]
          install_fake_on_all_instances(klass, method_name, method)
        elsif 
          install_fake_on_class(klass, method_name, method)
        end
      else
        if klass.kind_of?(Numeric)
          install_fake_on_all_instances(klass.class, method_name, method)  
        else
          install_fake_on_instance(klass, method_name, method)
        end
      end
    end

    def self.get_double(subject, method_name)
      return @@current_methods[subject][method_name.to_s]
    end

    def self.remember_swap(subject, method_name, original_method, new_method, type)
      if !@@originals.key?(subject)
        @@originals[subject] = {}
      end

      if !@@current_methods.key?(subject)
        @@current_methods[subject] = {}
      end

      @@current_methods[subject][method_name] = new_method

      #If we've already done a swap, we already have the original and
      #do not want to overwrite it
      if @@originals[subject].key?(method_name)
        return
      end

      @@originals[subject][method_name] = {:original_method => original_method,
                                           :type => type}
    end

    def self.unswap
      @@originals.each do |subject_name, hash_for_subject|
        hash_for_subject.each do |method_name, hash_for_method_name|
          swap_type = hash_for_method_name[:type]
          if swap_type == :class
            uninstall_fake_on_class(subject_name, method_name)
          elsif swap_type == :all_instances
            uninstall_fake_on_all_instances(subject_name, method_name)
          elsif swap_type == :instance
            uninstall_fake_on_instance(subject_name, method_name)
          end
        end
      end
    end

    private
    def self.install_fake_on_class(klass, method_name, method)
      klass.module_eval do
        RDouble::Fake.remember_swap(klass, method_name, method(method_name), method, :class)
        define_singleton_method method_name do |*args|
           method.call(self, *args) 
        end
      end
    end

    def self.install_fake_on_all_instances(klass, method_name, method)
      klass.module_eval do
        RDouble::Fake.remember_swap(klass, method_name, instance_method(method_name), method, :all_instances) 
        define_method method_name do |*args|
           method.call(self, *args) 
        end
      end
    end

    def self.install_fake_on_instance(instance, method_name, method)
      instance.instance_eval do
        RDouble::Fake.remember_swap(instance, method_name, method(method_name), method, :instance)
        define_singleton_method method_name do |*args|
          method.call(self, *args)
        end
      end
    end

    def self.uninstall_fake_on_class(subject, method_name)
      original_method = @@originals[subject][method_name][:original_method]
      @@originals[subject].delete(method_name)
      subject.module_eval do
        define_singleton_method(method_name, original_method)
      end
    end

    def self.uninstall_fake_on_all_instances(klass, method_name)
      original_method = @@originals[klass][method_name][:original_method]
      @@originals[klass].delete(method_name)
      klass.module_eval do
        define_method(method_name, original_method)
      end
    end

    def self.uninstall_fake_on_instance(instance, method_name)
      original_method = @@originals[instance][method_name][:original_method]
      @@originals[instance].delete(method_name)
      instance.instance_eval do
        define_singleton_method(method_name, original_method)
      end
    end
  end
end
