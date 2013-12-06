# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'ffi-gdal/version'

Gem::Specification.new do |gem|
  gem.name = 'ffi-gdal'
  gem.version = OGR::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.description = 'FFI wrapper for GDAL'
  gem.summary = 'Convenient access to GDAL functionality from Ruby'
  gem.licenses = ['MIT']

  gem.authors = ['Scooter Wadsworth']
  gem.email = ['scooterwadsworth@gmail.com']
  gem.homepage = 'https://github.com/scooterw/ffi-gdal'

  gem.required_ruby_version = '>= 1.9.2'
  gem.required_rubygems_version = '>= 1.3.6'

  gem.files = Dir['README.md', 'bin/**/*', 'lib/**/*']
  gem.require_paths = ['lib']
  gem.bindir = 'bin'
  gem.executables = ['ogr_console']

  gem.add_dependency 'ffi', '>= 1.6.0'
  
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
end

