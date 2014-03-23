sql_search_parser
=================

Simple SQL search conditions parser (where clause) based on RACC

Usage
-----
    SQLSearch::Parser.new.parse("a = 2")
    => #<SQLSearch::Comparison:0x00000000fd12e0 @left=#<SQLSearch::Atoms::Column:0x00000000fd1588 @name="a", @table=nil, @space=nil>, @right=#<SQLSearch::Atoms::Literal:0x00000000fd1380 @value=2, @type=:int>, @operator=:"=">
    
    SQLSearch::Parser.new.parse("a = 2 and b = 3").to_s
    => "(`a` = 2) AND (`b` = 3)" 
