Gem::Specification.new do |s|
  s.name = 'rdouble'
  s.version = '0.0.4'
  s.date = '2013-04-16'
  s.summary = 'Test Doubles in Ruby'
  s.description = 'Stubs, Spies and Fakes'
  s.authors = ['Krieghan J. Riley']
  s.email = 'krieghan.riley@gmail.com'
  s.files = `git ls-files`.split("\n")
  s.files.delete(".gitignore")
  s.add_development_dependency('test-unit')
  s.add_development_dependency('ruby-debug19')
  s.add_development_dependency('ruby-debug-base19')
  s.require_paths = ["lib"]
end
