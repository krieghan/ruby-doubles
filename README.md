ruby-doubles
============

Stubs, Spies and Fakes.  Mocks are not supported, because they are dumb (yes, really).

A word on the interface:

The interface is intended to be simple and non-intrusive (I do not, for instance, monkey-patch a "stubs" method onto Object, which would be an abomination before God and Man).

Anything in the public interface can be called using the module, for instance:

```ruby
RDouble::create_stub(:a => 1)
```

If this is intrusive to you, you can include RDouble in your class, which would give you access to everything without being explicit with the RDouble:

```ruby
class TestThisThing
  include RDouble
  
  def test_1
    a = create_stub(:a => 1)
  end
```

My background is in Python, so I prefer explicit to implicit.  However, you *really* should include RDouble 
in any test class, because it automatically includes a teardown that rolls back all the swaps at the end.  This 
is more than just a nice-to-have, it is essential for keeping your tests isolated.

Example class:

My examples will generally be using this class:

```ruby
class KlassA
  def self.klass_method
    return "KlassA.klass_method" 
  end
  
  def klass_a_instance_method
    return "KlassA.klass_a_instance_method"
  end
end

def fake_method_b(this)
  return "fake_method_b"
end

class FakeKlass
  def fake_method(this)
    return [this, self]
  end
end
```

Notice the "this" argument to my fake method b.  Yes, it is peculiar.  We'll talk about it later.

Fakes:
Everything in ruby-doubles is built on the notion of swapping an existing function with another function
at run-time, with an easily-understood syntax, that can be easily undone later.  In ruby, this is traditionally
accomplished on a one-off basis by "opening up" the class and changing the implementation.  If you want the ability to
roll it back later, you need to alias the old implementation to another name for safe-keeping.  I'm not going to
demonstrate that, because it is ugly and dumb (yes, really).  

I should note, when it comes to test doubles you usually want a Stub or a Spy.  A Fake is used in those special
situations where you require some sophistication.  If you are not a sophisticated person, and just want stubs
and spies (which is perfectly reasonable), and you don't care about what Stubs and Spies are based on in 
ruby-doubles, you can just skip the following section on Fakes.

Here is how you swap Fakes using ruby-doubles:

Swapping a class method:
```ruby
result = KlassA.klass_method
#result is now "KlassA.klass_method"
RDouble::swap_double(KlassA, :klass_method, method(:fake_method_b))
result = KlassA.klass_method
#result is now "fake_method_b"
```

Swapping an instance method:
```ruby
a = KlassA.new()
result = a.klass_a_instance_method
#result is now "KlassA.klass_a_instance_method"
RDouble::swap_double(a, :klass_a_instance_method, method(:fake_method_b))
result = a.klass_a_instance_method
#result is now "fake_method_b
```

Swapping for all instances of a class:

```ruby
a1 = KlassA.new()
a2 = KlassA.new()
#a1 and a2 both return "KlassA.klass_a_instance_method" if you call klass_a_instance_method on them
RDouble::swap_double(KlassA, :klass_a_instance_method, method(:fake_method_b), :all_instances => true)
a3 = KlassA.new()
#a1, a2, and a3 now both return "fake_method_b" when klass_a_instance_method is called
```

Let's talk about the "this" argument now.  Any fake method that we want to swap in requires a "this"
argument.  This is the only way that I could figure out to give the method access to the instance or 
class that was calling it.  The original method has full access to "self", and any instance 
variables or private methods contained therein.  The fake method only has access to the public
interface of "this".  This is annoying, but acceptable, as Ruby gives you ways to access both the 
instance variables and the private methods of "this".

"this" will be set to the receiver of whatever method you are replacing.  If you are replacing a class method, 
"this" is the class.  If you are replacing an instance method, "this" is the instance.

As you might expect, "self" in the fake method is whatever it was before the swap.  It is

1. Undefined if your fake method is not attached to a class or instance
2. Refers to the class or instance that it is attached to, otherwise.

Here is an example that illustrates this:

```ruby
a = KlassA.new()
RDouble::swap_double(a, :klass_a_instance_method, FakeKlass.instance_method(:fake_method))
result = a.klass_a_instance_method
#result is [KlassA, FakeKlass]
```

Stubs:

Stubs are just generic objects that are set up to have certain attributes set to known values.  
Here is how you make one with ruby-doubles:

```ruby
mystub = RDouble::create_stub(:a => 1, :b => 2)
result = mystub.a
# result is now 1
result = mystub.b
# result is now 2
```

"Stubbing" a function:

A function can be "swapped" with another function that just returns a given value.  This is called
"stubbing" the function:

```ruby
result = KlassA.klass_method
#result is now "KlassA.klass_method"
RDouble::install_stub(KlassA, :klass_method, :returns => "stubbed_klass_method")
result = KlassA.klass_method
#result is now "stubbed_klass_method"
```

Spy Functions:

Spy Functions are like Stubs (In my implementation, SpyFunction inherits from StubFunction).  They return whatever
you want them to.  However, they also remember each time they are called, and with what arguments.  This is
extremely useful if you have an external service that you are trying to use (like a Database or some 
HTTP server somewhere) that you don't want to actually use in your test (usually because of performance).  In
cases like these, what you want is to capture the calls to these services and make assertions about them.





