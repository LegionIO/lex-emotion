# frozen_string_literal: true

require_relative 'lib/legion/extensions/emotion/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-emotion'
  spec.version       = Legion::Extensions::Emotion::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Emotion'
  spec.description   = 'Multi-dimensional emotional valence for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-emotion'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-emotion'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-emotion'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-emotion'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-emotion/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-emotion.gemspec Gemfile LICENSE README.md]
  end
  spec.require_paths = ['lib']
end
