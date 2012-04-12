$:.push File.expand_path('../lib', __FILE__)
require 'adyen-skinbuilder/version'

Gem::Specification.new do |s|
  s.name        = 'adyen-skinbuilder'
  s.version     = Adyen::Skinbuilder::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Priit Haamer', 'Tobias Bielohlawek']
  s.email       = ['priit@edicy.com', 'tobi@soundcloud.com']
  s.homepage    = 'http://rubygems.org/gems/adyen-skinbuilder'
  s.summary     = %q{Simple Sinatra server to make coding Adyen skins easier}
  s.description = %q{Provides helpful command line tools to run sinatra server and bundle adyen skin files}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  %w(sinatra sinatra-contrib vegas adyen-admin).each do |gem|
    s.add_runtime_dependency *gem.split(' ')
  end

  %w(rake rspec guard-rspec rack-test).each do |gem|
    s.add_development_dependency *gem.split(' ')
  end
end
