# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ephemeral_response}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sandro Turriate", "Les Hill"]
  s.date = %q{2010-06-29}
  s.description = %q{
    Save HTTP responses to give your tests a hint of reality.
    Responses are saved into your fixtures directory and are used for subsequent web requests until they expire.
    }
  s.email = %q{sandro.turriate@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.markdown",
     "MIT_LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "examples/custom_cache_key.rb",
     "examples/simple_benchmark.rb",
     "examples/white_list.rb",
     "lib/ephemeral_response.rb",
     "lib/ephemeral_response/configuration.rb",
     "lib/ephemeral_response/fixture.rb",
     "lib/ephemeral_response/net_http.rb",
     "lib/ephemeral_response/request.rb",
     "spec/ephemeral_response/configuration_spec.rb",
     "spec/ephemeral_response/fixture_spec.rb",
     "spec/ephemeral_response/net_http_spec.rb",
     "spec/ephemeral_response_spec.rb",
     "spec/integration/custom_identifier_spec.rb",
     "spec/integration/normal_flow_spec.rb",
     "spec/integration/unique_fixtures_spec.rb",
     "spec/integration/white_list_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/support/clear_fixtures.rb",
     "spec/support/fakefs_ext.rb",
     "spec/support/rack_reflector.rb",
     "spec/support/time.rb"
  ]
  s.homepage = %q{http://github.com/sandro/ephemeral_response}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Save HTTP responses to give your tests a hint of reality.}
  s.test_files = [
    "spec/ephemeral_response/configuration_spec.rb",
     "spec/ephemeral_response/fixture_spec.rb",
     "spec/ephemeral_response/net_http_spec.rb",
     "spec/ephemeral_response_spec.rb",
     "spec/integration/custom_identifier_spec.rb",
     "spec/integration/normal_flow_spec.rb",
     "spec/integration/unique_fixtures_spec.rb",
     "spec/integration/white_list_spec.rb",
     "spec/spec_helper.rb",
     "spec/support/clear_fixtures.rb",
     "spec/support/fakefs_ext.rb",
     "spec/support/rack_reflector.rb",
     "spec/support/time.rb",
     "examples/custom_cache_key.rb",
     "examples/simple_benchmark.rb",
     "examples/white_list.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0.5.0"])
      s.add_development_dependency(%q<fakefs>, [">= 0.2.1"])
      s.add_development_dependency(%q<unicorn>, [">= 1.0.0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0.5.0"])
      s.add_dependency(%q<fakefs>, [">= 0.2.1"])
      s.add_dependency(%q<unicorn>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0.5.0"])
    s.add_dependency(%q<fakefs>, [">= 0.2.1"])
    s.add_dependency(%q<unicorn>, [">= 1.0.0"])
  end
end
