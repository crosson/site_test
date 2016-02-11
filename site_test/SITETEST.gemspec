Gem::Specification.new do |s|
  s.name        = 'site_test'
  s.version     = '0.1.3'
  s.date        = '2016-01-01'
  s.summary     = "Automated Functional testing for network engineers."
  s.description = "Update: http check ignores certs for https sites now. Use SSL check for site cert validation"
  s.authors     = ["Cliff Rosson"]
  s.email       = 'Cliff.rosson@gmail.com'
  s.files       = ["lib/site_test.rb"]
  s.homepage    =
    'https://github.com/crosson/site_test/'
  s.license       = ''
  s.add_runtime_dependency "net-ping", ">=1.7.4"
  s.add_runtime_dependency "rspec", ">=3"
end
