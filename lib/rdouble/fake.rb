module RDouble
  class Fake
    @@originals = {}
    @@current_methods = {}

    public
    def self.swap(subject, method_name, method, options={})
      defaults = {:all_instances => false}
      options = defaults.merge(options)
      if [Class, Module].include?(subject.class)
        if options[:all_instances]
          install_fake_on_all_instances(subject, method_name, method)
        elsif 
          install_fake_on_class(subject, method_name, method)
        end
      else
        if subject.kind_of?(Numeric)
          install_fake_on_all_instances(subject.class, method_name, method)  
        else
          install_fake_on_instance(subject, method_name, method)
        end
      end
    end

    if RUBY_VERSION.to_f >= 1.9
      def self.define_singleton_method_for_subject(subject, method_name, *args, &block)
        if block_given?
          subject.define_singleton_method(method_name, &block) 
        else
          subject.define_singleton_method(method_name, args[0])
        end  
      end
    else
      def self.define_singleton_method_for_subject(subject, method_name, *args, &block)
        singleton = class << subject; self end
        if block_given?
          singleton.send(:define_method, method_name, &block)
        else
          singleton.send(:define_method, method_name, args[0])
        end
      end
    end

    def self.get_double(subject, method_name)
      if !@@current_methods.key?(subject) || !@@current_methods[subject].key?(method_name.to_s)
        raise Exception.new("#{method_name} was never swapped for #{subject}")
      end

      return @@current_methods[subject][method_name.to_s]
    end

    def self.remember_swap(subject, method_name, original_method, new_method, type)
      if !@@originals.key?(subject)
        @@originals[subject] = {}
      end

      if !@@current_methods.key?(subject)
        @@current_methods[subject] = {}
      end

      @@current_methods[subject][method_name.to_s] = new_method

      #If we've already done a swap, we already have the original and
      #do not want to overwrite it
      if @@originals[subject].key?(method_name)
        return
      end

      @@originals[subject][method_name.to_s] = {:original_method => original_method,
                                                :type => type}
    end

    def self.unswap_method_for_subject(subject, method_name)
      hash_for_method_name = @@originals[subject][method_name]
      swap_type = hash_for_method_name[:type]
      if swap_type == :class
        uninstall_fake_on_class(subject, method_name)
      elsif swap_type == :all_instances
        uninstall_fake_on_all_instances(subject, method_name)
      elsif swap_type == :instance
        uninstall_fake_on_instance(subject, method_name)
      end
    end

    def self.unswap_all_for_subject(subject)
      hash_for_subject = @@originals[subject]
      if hash_for_subject.nil?
        return
      end
      hash_for_subject.keys.each do |method_name|
        unswap_method_for_subject(subject, method_name)
      end
    end

    def self.unswap
      @@originals.keys.each do |subject|
        unswap_all_for_subject(subject)
      end
      @@originals = {}
      @@current_methods = {}
    end

    private

    def self.install_fake_on_class(klass, method_name, method)
      RDouble::Fake.remember_swap(klass, method_name, klass.method(method_name), method, :class)
      klass.module_eval do
        RDouble::Fake.define_singleton_method_for_subject(klass, method_name) do |*args|
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
        RDouble::Fake.define_singleton_method_for_subject(instance, method_name) do |*args|
          method.call(self, *args)
        end
      end
    end

    def self.uninstall_fake_on_class(subject, method_name)
      original_method = @@originals[subject][method_name][:original_method]
      @@current_methods[subject].delete(method_name)
      @@originals[subject].delete(method_name)
      RDouble::Fake.define_singleton_method_for_subject(subject, method_name, original_method)
    end

    def self.uninstall_fake_on_all_instances(klass, method_name)
      original_method = @@originals[klass][method_name][:original_method]
      @@originals[klass].delete(method_name)
      @@current_methods[klass].delete(method_name)
      klass.send(:define_method, method_name, original_method)
    end

    def self.uninstall_fake_on_instance(instance, method_name)
      original_method = @@originals[instance][method_name][:original_method]
      @@originals[instance].delete(method_name)
      @@current_methods[instance].delete(method_name)
      RDouble::Fake.define_singleton_method_for_subject(instance, method_name, original_method)
    end
  end
end
