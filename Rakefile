$:.unshift File.expand_path('../lib', __FILE__)
require 'ffi-gdal/version'

task :build do
  system 'gem build ffi-gdal.gemspec'
end

task :release => :build do
  system "gem push ffi-gdal-#{GDAL::VERSION}.gem"
end

require 'rspec/core/rake_task'
task :default => :spec
RSpec::Core::RakeTask.new

