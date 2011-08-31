# -*- encoding: utf-8 -*-
require File.expand_path('../lib/altum/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Larry Marburger"]
  gem.email         = ["larry@marburger.cc"]
  gem.description   = %q{Drive ShowOff remotely}
  gem.summary       = %q{Altum uses the magic of Pusher and websockets to drive a ShowOff presentation remotely. The simplest tool to walk through a deck on a conference call.}
  gem.homepage      = "http://lmarburger.github.com/altum/"

  gem.add_dependency 'pusher'
  gem.add_dependency 'rack'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'wrong'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "altum"
  gem.require_paths = ["lib"]
  gem.version       = Altum::VERSION
end
