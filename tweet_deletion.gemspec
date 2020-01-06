# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tweet_deletion/version'

Gem::Specification.new do |spec|
  spec.name          = "tweet_deletion"
  spec.version       = TweetDeletion::VERSION
  spec.authors       = ["Éric D."]
  spec.email         = ["eric.daspet@survol.fr"]

  spec.summary       = "Delete your tweets and favorites programmaticaly"
  spec.homepage      = "https://github.com/edas/TweetDeletion"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "twitter"
  spec.add_dependency "activesupport"
  spec.add_dependency "mastodon-api"
  spec.add_dependency "oauth2"
  spec.add_dependency "loofah"
  spec.add_dependency "twitter_oauth"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
end
