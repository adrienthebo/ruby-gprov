require 'rubygems'
require 'rubygems/package_task'

PKG_FILES = Dir["lib/**/*"] + Dir["[A-Z]*"]

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'gprov'
  s.author = 'Adrien Thebo'
  s.email  = 'adrien@puppetlabs.com'
  s.homepage = 'http://github.com/adrienthebo/ruby-gprov'
  s.files = PKG_FILES
  s.summary = "Ruby bindings to the Google Provisioning API"
  s.description = "Ruby bindings to the Google Provisioning API"
  s.version = GProv::VERSION
  s.add_dependency('httparty', ">= 0.8")
  s.add_dependency('nokogiri', ">= 1.5")
  s.require_path = 'lib'
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
