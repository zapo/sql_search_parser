require_relative 'lib/sql_search/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'sql_search_parser'
  s.version     = SQLSearch::VERSION
  s.date        = Time.now.to_date
  s.summary     = "Simple SQL search conditions parser (where clause)"
  s.description = "Simple SQL search conditions parser (where clause)"
  s.authors     = ["Antoine Niek"]
  s.email       = 'antoineniek@gmail.com'
  s.files       = %w(LICENSE README.md Rakefile) + Dir.glob("lib/**/*")
  s.homepage    = 'https://github.com/zapo/sql_search_parser'
  s.license     = 'MIT'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rexical'
  s.add_development_dependency 'racc'
end
