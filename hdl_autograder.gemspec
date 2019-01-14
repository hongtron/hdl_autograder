# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require "hdl_autograder/version"

Gem::Specification.new do |gem|
  gem.authors       = ["Ali Hong"]
  gem.email         = ["github@alihong.net"]
  gem.summary       = "Autograder for nand2tetris hdl assignments"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hdl_autograder"
  gem.require_paths = ["lib"]
  gem.version       = HdlAutograder::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry-rescue", '>= 1.5.0'
  gem.add_development_dependency "pry-byebug"
end
