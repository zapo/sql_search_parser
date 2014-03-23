require_relative '../../test_helper'

module SQLSearch
  class ParserTest < Minitest::Test

    def test_comparisons
      assert_equal "`b` = 3",
        SQLSearch::Parser.new.parse("b = 3").to_s
      assert_equal "`b` <> 3",
        SQLSearch::Parser.new.parse("b <> 3").to_s
      assert_equal "`b` > 3",
        SQLSearch::Parser.new.parse("b > 3").to_s
      assert_equal "`b` < 3",
        SQLSearch::Parser.new.parse("b < 3").to_s
      assert_equal "`b` <= 3",
        SQLSearch::Parser.new.parse("b <= 3").to_s
      assert_equal "`b` >= 3",
        SQLSearch::Parser.new.parse("b >= 3").to_s
      assert_equal "`b` = NULL",
        SQLSearch::Parser.new.parse("b is null").to_s
      assert_equal "`b` <> NULL",
        SQLSearch::Parser.new.parse("b is not null").to_s
      assert_equal "`b` LIKE '%3%'",
        SQLSearch::Parser.new.parse("b like '%3%'").to_s
      assert_equal "NOT(`b` LIKE '%3%')",
        SQLSearch::Parser.new.parse("b not like '%3%'").to_s
      assert_equal "`b` IN (1, 2, 3)",
        SQLSearch::Parser.new.parse("b in (1,2,3)").to_s
      assert_equal "NOT(`b` IN (1, 2, 3))",
        SQLSearch::Parser.new.parse("b not in (1,2,3)").to_s
    end

    def test_atom_parse
      assert_equal Date.iso8601('2013-01-01T00:00:00Z'),
        SQLSearch::Parser.new.parse("b = '2013-01-01T00:00:00Z'").right.value

      assert_equal 'blah',
        SQLSearch::Parser.new.parse("b = 'blah'").right.value

      assert_equal 1,
        SQLSearch::Parser.new.parse("b = 1").right.value

      assert_equal 1.1,
        SQLSearch::Parser.new.parse("b = 1.1").right.value
    end

    def test_conditions
      assert_equal "(`b` = 3) AND (`c` = 1)",
        SQLSearch::Parser.new.parse("b = 3 and c = 1").to_s
      assert_equal "(`b` = 3) OR (`c` = 1)",
        SQLSearch::Parser.new.parse("b = 3 or c = 1").to_s
      #assert_equal "NOT(`b` = 3) OR (`c` = 1)",
      #  SQLSearch::Parser.new.parse("not(b = 3) or c = 1").to_s
    end
  end
end
