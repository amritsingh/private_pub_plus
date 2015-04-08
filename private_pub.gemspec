Gem::Specification.new do |s|
  s.name        = "private_pub"
  s.version     = "1.0.3"
  s.author      = "Amrit Singh"
  s.email       = "amrit0403@gmail.com"
  s.homepage    = "http://github.com/amritsingh/private_pub"
  s.summary     = "Private pub/sub messaging in Rails."
  s.description = "Private pub/sub messaging in Rails through Faye. Modified the private pub gem from https://github.com/ryanb/private_pub to make it customizable. Removed js support"

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'faye'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.8.0'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
