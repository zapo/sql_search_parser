require_relative 'lib/sql_search/version'
require 'rake/testtask'

desc "Generate Lexer"

task :lexer do
  `rex lib/sql_search/parser.rex -o lib/sql_search/parser.rex.rb`
end

task :parser do
  `racc lib/sql_search/parser.y -o lib/sql_search/parser.racc.rb`
end

task :build => [:lexer, :parser]

task :package => [:build] do
  `gem build sql_search_parser.gemspec`
  `gem install sql_search_parser-#{SQLSearch::VERSION}.gem`
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task :default => [:test]

