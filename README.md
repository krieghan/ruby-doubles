ruby-doubles
============

Stubs, Spies and Fakes.  Mocks are not supported, because they are dumb (yes, really).

The interface is intended to be simple and non-intrusive (I do not, for instance, monkey-patch a "stubs" method onto Object, which would be an abomination before God and Man).

Stubs:

Stubs are just generic objects that are set up to have certain attributes set to known values.  Here is how you make one:

> mystub = RDouble::create_stub(:a => 1, :b => 2)
> mystub.a
1
> mystub.b
2




