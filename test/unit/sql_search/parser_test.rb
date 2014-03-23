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

      scalar_add = SQLSearch::Parser.new.parse("b = 1 + 1").right
      assert_equal "1 + 1", scalar_add.to_s
      assert_equal 1, scalar_add.left.value
      assert_equal 1, scalar_add.right.value
      assert_equal :'+', scalar_add.operation

      scalar_add = SQLSearch::Parser.new.parse("b = 1 + 1").right
      assert_equal "1 + 1", scalar_add.to_s
      assert_equal 1, scalar_add.left.value
      assert_equal 1, scalar_add.right.value
      assert_equal :'+', scalar_add.operation

      scalar_subtract = SQLSearch::Parser.new.parse("b = 1 - 1").right
      assert_equal "1 - 1", scalar_subtract.to_s
      assert_equal 1, scalar_subtract.left.value
      assert_equal 1, scalar_subtract.right.value
      assert_equal :'-', scalar_subtract.operation

      scalar_multiply = SQLSearch::Parser.new.parse("b = 1 * 1.1").right
      assert_equal "1 * 1.1", scalar_multiply.to_s
      assert_equal 1, scalar_multiply.left.value
      assert_equal 1.1, scalar_multiply.right.value
      assert_equal :'*', scalar_multiply.operation

      scalar_divide = SQLSearch::Parser.new.parse("b = 1.1 / 1").right
      assert_equal "1.1 / 1", scalar_divide.to_s
      assert_equal 1.1, scalar_divide.left.value
      assert_equal 1, scalar_divide.right.value
      assert_equal :'/', scalar_divide.operation

      abs_unary_scalar = SQLSearch::Parser.new.parse("b = +c")
      assert_equal :'+', abs_unary_scalar.right.operation
      assert_equal "`b` = +`c`", abs_unary_scalar.to_s
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
