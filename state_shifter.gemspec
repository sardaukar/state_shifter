# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: state_shifter 1.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "state_shifter"
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bruno Antunes"]
  s.date = "2015-08-01"
  s.description = "state_shifter is a gem that adds state machine behavior to a class"
  s.email = "sardaukar.siet@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "examples/advanced.rb",
    "examples/malformed_events.rb",
    "examples/malformed_persistence.rb",
    "examples/malformed_states.rb",
    "examples/missing_persistence.rb",
    "examples/review.rb",
    "examples/review_custom_persistence.rb",
    "examples/simple.rb",
    "lib/state_shifter.rb",
    "lib/state_shifter/definition.rb",
    "lib/state_shifter/definition/active_record_integration_methods.rb",
    "lib/state_shifter/definition/class_methods.rb",
    "lib/state_shifter/definition/contents.rb",
    "lib/state_shifter/definition/instance_methods.rb",
    "lib/state_shifter/draw.rb",
    "lib/state_shifter/event.rb",
    "lib/state_shifter/railtie.rb",
    "lib/state_shifter/state.rb",
    "lib/tasks/state_shifter.rake",
    "spec/spec_helper.rb",
    "spec/state_shifter_spec.rb",
    "state_shifter.gemspec"
  ]
  s.homepage = "http://github.com/sardaukar/state_shifter"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.6"
  s.summary = "state_shifter is a gem that adds state machine behavior to a class"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<activerecord>, ["~> 4.1.11"])
      s.add_development_dependency(%q<rack>, ["~> 1.5.4"])
      s.add_development_dependency(%q<sqlite3>, [">= 1.3.10", "~> 1.3"])
      s.add_development_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<redcarpet>, [">= 3.2.3", "~> 3.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.7.12", "~> 1.7"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0"])
      s.add_development_dependency(%q<pry>, ["~> 0"])
      s.add_development_dependency(%q<ruby-graphviz>, [">= 1.2.2", "~> 1.2"])
      s.add_development_dependency(%q<json>, [">= 1.8.2", "~> 1.8"])
      s.add_development_dependency(%q<i18n>, [">= 0.6.6", "~> 0.6"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.6.3"])
    else
      s.add_dependency(%q<activerecord>, ["~> 4.1.11"])
      s.add_dependency(%q<rack>, ["~> 1.5.4"])
      s.add_dependency(%q<sqlite3>, [">= 1.3.10", "~> 1.3"])
      s.add_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<redcarpet>, [">= 3.2.3", "~> 3.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<bundler>, [">= 1.7.12", "~> 1.7"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<simplecov>, ["~> 0"])
      s.add_dependency(%q<pry>, ["~> 0"])
      s.add_dependency(%q<ruby-graphviz>, [">= 1.2.2", "~> 1.2"])
      s.add_dependency(%q<json>, [">= 1.8.2", "~> 1.8"])
      s.add_dependency(%q<i18n>, [">= 0.6.6", "~> 0.6"])
      s.add_dependency(%q<nokogiri>, [">= 1.6.3"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 4.1.11"])
    s.add_dependency(%q<rack>, ["~> 1.5.4"])
    s.add_dependency(%q<sqlite3>, [">= 1.3.10", "~> 1.3"])
    s.add_dependency(%q<rspec>, ["~> 3.2.0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<redcarpet>, [">= 3.2.3", "~> 3.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<bundler>, [">= 1.7.12", "~> 1.7"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<simplecov>, ["~> 0"])
    s.add_dependency(%q<pry>, ["~> 0"])
    s.add_dependency(%q<ruby-graphviz>, [">= 1.2.2", "~> 1.2"])
    s.add_dependency(%q<json>, [">= 1.8.2", "~> 1.8"])
    s.add_dependency(%q<i18n>, [">= 0.6.6", "~> 0.6"])
    s.add_dependency(%q<nokogiri>, [">= 1.6.3"])
  end
end

