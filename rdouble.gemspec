Gem::Specification.new do |s|
  s.name = 'rdouble'
  s.version = '0.0.1'
  s.date = '2013-04-16'
  s.summary = 'Test Doubles in Ruby'
  s.description = 'Stubs, Spies and Fakes'
  s.authors = ['Krieghan J. Riley']
  s.email = 'krieghan.riley@gmail.com'
  s.files = `git ls-files`.split("\n")
  s.files.delete(".gitignore")
  s.require_paths = ["lib"]
end
