require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ephemeral_response"
    gem.summary = %Q{Save HTTP responses to give your tests a hint of reality.}
    gem.description = %Q{
    Save HTTP responses to give your tests a hint of reality.
    Responses are saved into your fixtures directory and are used for subsequent web requests until they expire.
    }
    gem.email = "sandro.turriate@gmail.com"
    gem.homepage = "http://github.com/sandro/ephemeral_response"
    gem.authors = ["Sandro Turriate"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0.5.0"
    gem.add_development_dependency "fakefs", ">= 0.2.1"
    gem.add_development_dependency "unicorn", ">= 1.0.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
