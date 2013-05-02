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

Some example classes:


Stubs:

Stubs are just generic objects that are set up to have certain attributes set to known values.  
Here is how you make one with ruby-doubles:

```ruby
mystub = RDouble::create_stub(:a => 1, :b => 2)
mystub.a
mystub.b
```

line 2 evaluates to "1", line 3 evaluates to "2".  Nothing complicated.

"Stubbing" a function:

A function can be "swapped" with another function that just returns a given value.  This is called
"stubbing" the function:

```ruby
RDouble::install_stub(



