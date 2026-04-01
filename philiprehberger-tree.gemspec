# frozen_string_literal: true

require_relative 'lib/philiprehberger/tree/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-tree'
  spec.version       = Philiprehberger::Tree::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'Generic tree data structure with traversal, search, and serialization'
  spec.description   = 'A generic tree data structure supporting depth-first and breadth-first traversal, ' \
                       'node search, path finding, and hash serialization. Each node tracks its parent, ' \
                       'children, depth, height, and size.'
  spec.homepage      = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-tree'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/philiprehberger/rb-tree'
  spec.metadata['changelog_uri']         = 'https://github.com/philiprehberger/rb-tree/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/philiprehberger/rb-tree/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
