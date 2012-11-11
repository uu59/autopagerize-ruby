# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'autopagerize/version'

Gem::Specification.new do |gem|
  gem.name          = "autopagerize"
  gem.version       = Autopagerize::VERSION
  gem.authors       = ["uu59"]
  gem.email         = ["k@uu59.org"]
  gem.description   = %q{Concat paginated web pages to single page}
  gem.summary       = %q{Concat paginated web pages to single page}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "addressable"
  gem.add_dependency "httpclient"
  gem.add_dependency "nokogiri"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "multi_json"
end
