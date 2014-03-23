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
