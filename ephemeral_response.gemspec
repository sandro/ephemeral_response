lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'ephemeral_response'

Gem::Specification.new do |s|
  s.required_rubygems_version = '>= 1.3.6'

  s.version = EphemeralResponse::VERSION.dup

  s.name = 'ephemeral_response'

  s.authors = ['Sandro Turriate', 'Les Hill']
  s.email = 'sandro.turriate@gmail.com'
  s.homepage = 'https://github.com/sandro/ephemeral_response'
  s.summary = 'Save HTTP responses to give your tests a hint of reality.'
  s.description = <<-EOD
    Save HTTP responses to give your tests a hint of reality.
    Responses are saved into your fixtures directory and are used for subsequent web requests until they expire.
  EOD

  s.require_path = 'lib'

  s.files = Dir.glob('lib/**/*') + %w(MIT_LICENSE README.markdown History.markdown Rakefile)

  s.add_development_dependency('rspec', ['>= 2.9.0'])
  s.add_development_dependency('fakefs', ['>= 0.4.0'])
  s.add_development_dependency('unicorn', ['>= 1.0.0'])
  s.add_development_dependency('debugger')
  s.add_development_dependency('yard', ['>= 0.7.2'])
end
