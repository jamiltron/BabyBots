# -*- encoding: utf-8 -*-
require File.expand_path('../lib/baby_bots/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Hamilton"]
  gem.email         = ["justinanthonyhamilton@gmail.com"]
  gem.description   = %q{A tiny finite-state automata library.}
  gem.summary       = %q{While there are many fsa libraries out there, I wanted to implement my own so I could learn how to create a module/gem, as I am not really a Ruby guy and have no idea how.}
  gem.homepage      = "https://github.com/jamiltron/BabyBots"
  gem.email         = "justinanthonyhamilton@gmail.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "baby_bots"
  gem.require_paths = ["lib"]
  gem.version       = BabyBots::VERSION
end
