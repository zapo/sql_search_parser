sql_search_parser
=================

Simple SQL search conditions parser (where clause) based on RACC

Usage
-----
    SQLSearch::Parser.new.parse("a = 2")
    => #<SQLSearch::Comparison:0x00000000fd12e0 @left=#<SQLSearch::Atoms::Column:0x00000000fd1588 @name="a", @table=nil, @space=nil>, @right=#<SQLSearch::Atoms::Literal:0x00000000fd1380 @value=2, @type=:int>, @operator=:"=">

    SQLSearch::Parser.new.parse("a = 2 and b = 3").to_s
    => "(`a` = 2) AND (`b` = 3)"

    SQLSearch::Parser.new.parse("b = '2013-01-01T00:00:00Z'").right.value
    => #<DateTime: 2013-01-01T00:00:00+00:00 ((2456294j,0s,0n),+0s,2299161j)>

    SQLSearch::Parser.new.parse("b = '2013-01-01T00:00:00-05:00'").right.value
    => #<DateTime: 2013-01-01T00:00:00-05:00 ((2456294j,18000s,0n),-18000s,2299161j)>
