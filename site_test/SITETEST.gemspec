Gem::Specification.new do |s|
  s.name        = 'site_test'
  s.version     = '0.1.5'
  s.date        = '2024-01-16'
  s.summary     = "Automated Functional testing for network engineers."
  s.description = "Update: Fixed outdated ssl_code call"
  s.authors     = ["Cliff Rosson"]
  s.email       = 'Cliff.rosson@gmail.com'
  s.files       = ["lib/site_test.rb"]
  s.homepage    =
    'https://github.com/crosson/site_test/'
  s.license       = ''
  s.add_runtime_dependency "net-ping", ">=1.7.4"
  s.add_runtime_dependency "rspec", ">=3"
end
