module RDouble
  class Fake
    @@originals = {}
    @@current_methods = {}

    public
    def self.swap(subject, method_name, method, options={})
      defaults = {:all_instances => false,
                  :namespace => :standard}
      options = defaults.merge(options)
      if [Class, Module].include?(subject.class)
        if options[:all_instances]
          install_fake_on_all_instances(subject, method_name, method, options)
        elsif 
          if RUBY_VERSION.to_f >= 1.9
            install_fake_on_class(subject, method_name, method, options)
          else
            install_fake_on_subtree(subject, method_name, method, options)
          end
        end
      else
        if subject.kind_of?(Numeric)
          install_fake_on_all_instances(subject.class, method_name, method, options)  
        else
          install_fake_on_instance(subject, method_name, method, options)
        end
      end
    end

    def self.add(subject, method_name, method, options={})
      options[:add] = true
      self.swap(subject, method_name, method, options) 
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

    def self.remember_swap(subject, method_name, original_method, new_method, type, options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]

      if !@@originals.key?(namespace)
        @@originals[namespace] = {}
      end

      if !@@originals[namespace].key?(subject)
        @@originals[namespace][subject] = {}
      end

      if !@@current_methods.key?(subject)
        @@current_methods[subject] = {}
      end

      @@originals.keys.each do |namespace_key|
        if namespace == namespace_key
          next
        end

        if @@originals[namespace_key].key?(subject)
          raise Exception.new("#{subject} already has fakes in another namespace #{namespace_key}")
        end
      end



      @@current_methods[subject][method_name.to_s] = new_method

      #If we've already done a swap, we already have the original and
      #do not want to overwrite it
      if @@originals[namespace][subject].key?(method_name)
        return
      end

      @@originals[namespace][subject][method_name.to_s] = {:original_method => original_method,
                                                           :type => type}
    end

    def self.unswap_method_for_subject(subject, method_name, options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]

      hash_for_method_name = @@originals[namespace][subject][method_name]
      swap_type = hash_for_method_name[:type]
      if swap_type == :class
        uninstall_fake_on_class(subject, method_name, options)
      elsif swap_type == :all_instances
        uninstall_fake_on_all_instances(subject, method_name, options)
      elsif swap_type == :instance
        uninstall_fake_on_instance(subject, method_name, options)
      end
    end

    def self.unswap_all_for_subject(subject, options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]
      
      hash_for_subject = @@originals[namespace][subject]
      if hash_for_subject.nil?
        return
      end
      hash_for_subject.keys.each do |method_name|
        unswap_method_for_subject(subject, method_name, options)
      end
    end

    def self.unswap(options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]

      if !@@originals.key?(namespace)
        @@originals[namespace] = {}
      end

      @@originals[namespace].keys.each do |subject|
        unswap_all_for_subject(subject, options)
        @@current_methods.delete(subject)
      end
      @@originals[namespace] = {}
    end

    private

    def self.install_fake_on_subtree(klass, method_name, method, options={})
      subclasses = ObjectSpace.each_object(::Class).select {|c| c.superclass == klass}
      subclasses.each do |subclass|
        if !subclass.methods(false).include?(method_name)
          install_fake_on_subtree(subclass, method_name, method, options)
        end
      end
      install_fake_on_class(klass, method_name, method, options)
    end

    def self.install_fake_on_class(klass, method_name, method, options={})
      if options[:add] && !klass.methods.include?(method_name)
        original_method = nil
      else
        original_method = klass.method(method_name)
      end

      RDouble::Fake.remember_swap(klass, method_name, original_method, method, :class, options)
      klass.module_eval do
        RDouble::Fake.define_singleton_method_for_subject(klass, method_name) do |*args|
          method.call(self, *args)
        end
      end
    end

    def self.install_fake_on_all_instances(klass, method_name, method, options={})
      if options[:add] && !klass.instance_methods.include?(method_name)
        original_method = nil
      else
        original_method = klass.instance_method(method_name)
      end
      klass.module_eval do
        RDouble::Fake.remember_swap(klass, method_name, original_method, method, :all_instances, options)
        define_method method_name do |*args|
           method.call(self, *args)
        end
      end
    end

    def self.install_fake_on_instance(instance, method_name, method, options={})
      if options[:add] && !instance.methods.include?(method_name)
        original_method = nil
      else
        original_method = instance.method(method_name)
      end

      instance.instance_eval do
        RDouble::Fake.remember_swap(instance, method_name, original_method, method, :instance, options)
        RDouble::Fake.define_singleton_method_for_subject(instance, method_name) do |*args|
          method.call(self, *args)
        end
      end
    end

    def self.uninstall_fake_on_subtree(subject, method_name, options={})
      subclasses = ObjectSpace.each_object(::Class).select {|c| c <= subject}
      subclasses.each do |subclass|
        uninstall_fake_on_class(subclass, method_name, options)
      end
    end

    def self.uninstall_fake_on_class(subject, method_name, options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]
      
      original_method = @@originals[namespace][subject][method_name][:original_method]
      if original_method.nil?
        subject.instance_eval("undef #{method_name}")
      else
        @@current_methods[subject].delete(method_name)
        if RUBY_VERSION.to_f >= 1.9
          @@originals[namespace][subject].delete(method_name)
          RDouble::Fake.define_singleton_method_for_subject(subject, method_name, original_method)
        else
          RDouble::Fake.define_singleton_method_for_subject(subject, method_name) do |*args|
            original_method.call(*args)
          end
        end
      end
    end

    def self.uninstall_fake_on_all_instances(klass, method_name, options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]

      original_method = @@originals[namespace][klass][method_name][:original_method]
      if original_method.nil?
        klass.instance_eval do 
          remove_method method_name
        end
      else
        @@originals[namespace][klass].delete(method_name)
        @@current_methods[klass].delete(method_name)
        klass.send(:define_method, method_name, original_method)
      end
    end

    def self.uninstall_fake_on_instance(instance, method_name, options={})
      defaults = {:namespace => :standard}
      options = defaults.merge(options)
      namespace = options[:namespace]

      original_method = @@originals[namespace][instance][method_name][:original_method]
      if original_method.nil?
        instance.instance_eval("undef #{method_name}")
      else
        @@originals[namespace][instance].delete(method_name)
        @@current_methods[instance].delete(method_name)
        RDouble::Fake.define_singleton_method_for_subject(instance, method_name, original_method)
      end
    end
  end
end

