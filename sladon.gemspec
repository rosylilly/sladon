# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sladon/version'

Gem::Specification.new do |spec|
  spec.name          = 'sladon'
  spec.version       = Sladon::VERSION
  spec.authors       = ['Sho Kusano']
  spec.email         = ['sho-kusano@space-pirates.jp']

  spec.summary       = 'Slack adapter of mastodn.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/dwango/sladon'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'mastodon-api'
  spec.add_dependency 'websocket-client-simple'
  spec.add_dependency 'slack-notifier'
  spec.add_dependency 'oj'
  spec.add_dependency 'thor'
end
