require './fake'
class A
  def a
    puts "a"
  end
end
              
def b
  puts "b"
end
      
RDouble.install_fake(A, "a", method(:b))
a = A.new()
a.a()
