require 'rubygems' unless ENV['NO_RUBYGEMS']
require 'rubygems/package_task'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = 'jabbit'
  s.version = '0.0.2'
  s.author = 'Michael Pirogov'
  s.email = 'vbnet.ru@gmail.com'
  s.homepage = 'https://megaplan.ru'
  s.description = s.summary = 'Jabber via RabbitMQ proxy.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = SUMMARY

  # Uncomment this to add a dependency
  # s.add_dependency "foo"

  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob('{lib,spec}/**/*')
end

task :default => :spec

desc 'Run specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end


Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc 'install the gem locally'
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc 'create a gemspec file'
task :make_spec do
  File.open("#{GEM}.gemspec", 'w') do |file|
    file.puts spec.to_ruby
  end
end
