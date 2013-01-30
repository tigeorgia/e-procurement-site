# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "paperclip"
  s.version = "3.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jon Yurek"]
  s.date = "2012-05-18"
  s.description = "Easy upload management for ActiveRecord"
  s.email = ["jyurek@thoughtbot.com"]
  s.homepage = "https://github.com/thoughtbot/paperclip"
  s.post_install_message = "##################################################\n#  NOTE FOR UPGRADING FROM PRE-3.0 VERSION       #\n##################################################\n\nPaperclip 3.0 introduces a non-backward compatible change in your attachment\npath. This will help to prevent attachment name clashes when you have\nmultiple attachments with the same name. If you didn't alter your\nattachment's path and are using Paperclip's default, you'll have to add\n`:path` and `:url` to your `has_attached_file` definition. For example:\n\n    has_attached_file :avatar,\n      :path => \":rails_root/public/system/:attachment/:id/:style/:filename\",\n      :url => \"/system/:attachment/:id/:style/:filename\"\n\n"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.requirements = ["ImageMagick"]
  s.rubyforge_project = "paperclip"
  s.rubygems_version = "1.8.24"
  s.summary = "File attachments as attributes for ActiveRecord"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<cocaine>, [">= 0.0.2"])
      s.add_runtime_dependency(%q<mime-types>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<appraisal>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<aws-sdk>, [">= 0"])
      s.add_development_dependency(%q<bourne>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, ["~> 1.3.4"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.1.0"])
      s.add_development_dependency(%q<aruba>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<capybara>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<cocaine>, ["~> 0.2"])
      s.add_development_dependency(%q<fog>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<launchy>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_dependency(%q<activemodel>, [">= 3.0.0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<cocaine>, [">= 0.0.2"])
      s.add_dependency(%q<mime-types>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<appraisal>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<aws-sdk>, [">= 0"])
      s.add_dependency(%q<bourne>, [">= 0"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3.4"])
      s.add_dependency(%q<cucumber>, ["~> 1.1.0"])
      s.add_dependency(%q<aruba>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<capybara>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<cocaine>, ["~> 0.2"])
      s.add_dependency(%q<fog>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<launchy>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 3.0.0"])
    s.add_dependency(%q<activemodel>, [">= 3.0.0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<cocaine>, [">= 0.0.2"])
    s.add_dependency(%q<mime-types>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<appraisal>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<aws-sdk>, [">= 0"])
    s.add_dependency(%q<bourne>, [">= 0"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3.4"])
    s.add_dependency(%q<cucumber>, ["~> 1.1.0"])
    s.add_dependency(%q<aruba>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<capybara>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<cocaine>, ["~> 0.2"])
    s.add_dependency(%q<fog>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<launchy>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end
