require_relative '../../test_helper'

module SQLSearch
  class ParserTest < Minitest::Test

    def test_comparisons
      assert_equal "`b` = TRUE",
        SQLSearch.parse("b = true").to_s
      assert_equal "`b` = ''",
        SQLSearch.parse("b = ''").to_s
      assert_equal "`b` != ''",
        SQLSearch.parse("b != ''").to_s
      assert_equal "`b` = FALSE",
        SQLSearch.parse("b = false").to_s
      assert_equal "(`name`.`col1` = FALSE) AND (`name`.`col2` = TRUE)",
        SQLSearch.parse("name.col1 = false and name.col2 = true").to_s
      assert_equal "`name`.`fa` = TRUE",
        SQLSearch.parse("name.fa = true").to_s
      assert_equal "`b` = 3",
        SQLSearch.parse("b = 3").to_s
      assert_equal "`b` <> 3",
        SQLSearch.parse("b <> 3").to_s
      assert_equal "`b` > 3",
        SQLSearch.parse("b > 3").to_s
      assert_equal "`b` < 3",
        SQLSearch.parse("b < 3").to_s
      assert_equal "`b` <= 3",
        SQLSearch.parse("b <= 3").to_s
      assert_equal "`b` >= 3",
        SQLSearch.parse("b >= 3").to_s
      assert_equal "`b` = NULL",
        SQLSearch.parse("b = null").to_s
      assert_equal "`b` <> NULL",
        SQLSearch.parse("b <> null").to_s
      assert_equal "`b` LIKE '%3%'",
        SQLSearch.parse("b like '%3%'").to_s
      assert_equal "NOT (`b` LIKE '%3%')",
        SQLSearch.parse("b not like '%3%'").to_s
      assert_equal "`b` IN (1, 2, 3)",
        SQLSearch.parse("b in (1,2,3)").to_s
      assert_equal "NOT (`b` IN (1, 2, 3))",
        SQLSearch.parse("b not in (1,2,3)").to_s
    end

    def test_atom_parse
      assert_equal "bl\\'ah",
        SQLSearch.parse("b = 'bl\\'ah'").right.value

      assert_equal ['a', 'b', 'c'], SQLSearch.parse("a.b.c = null").left.to_a

      assert_equal nil,
        SQLSearch.parse("b = null").right.value

      assert_equal Date.iso8601('2013-01-01T00:00:00Z'),
        SQLSearch.parse("b = '2013-01-01T00:00:00Z'").right.value

      assert_equal 'blah',
        SQLSearch.parse("b = 'blah'").right.value

      ['t', 'true'].each do |truth|
        assert_equal true,
          SQLSearch.parse("b = #{truth}").right.value
      end

      ['f', 'false'].each do |falseness|
        assert_equal false,
          SQLSearch.parse("b = #{falseness}").right.value
      end

      assert_equal 1,
        SQLSearch.parse("b = 1").right.value

      assert_equal 1.1,
        SQLSearch.parse("b = 1.1").right.value

      scalar_add = SQLSearch.parse("b = 1 + 1").right
      assert_equal "1 + 1", scalar_add.to_s
      assert_equal 1, scalar_add.left.value
      assert_equal 1, scalar_add.right.value
      assert_equal :'+', scalar_add.operation

      scalar_add = SQLSearch.parse("b = 1 + 1").right
      assert_equal "1 + 1", scalar_add.to_s
      assert_equal 1, scalar_add.left.value
      assert_equal 1, scalar_add.right.value
      assert_equal :'+', scalar_add.operation

      scalar_subtract = SQLSearch.parse("b = 1 - 1").right
      assert_equal "1 - 1", scalar_subtract.to_s
      assert_equal 1, scalar_subtract.left.value
      assert_equal 1, scalar_subtract.right.value
      assert_equal :'-', scalar_subtract.operation

      scalar_multiply = SQLSearch.parse("b = 1 * 1.1").right
      assert_equal "1 * 1.1", scalar_multiply.to_s
      assert_equal 1, scalar_multiply.left.value
      assert_equal 1.1, scalar_multiply.right.value
      assert_equal :'*', scalar_multiply.operation

      scalar_divide = SQLSearch.parse("b = 1.1 / 1").right
      assert_equal "1.1 / 1", scalar_divide.to_s
      assert_equal 1.1, scalar_divide.left.value
      assert_equal 1, scalar_divide.right.value
      assert_equal :'/', scalar_divide.operation

      abs_unary_scalar = SQLSearch.parse("b = +c")
      assert_equal :'+', abs_unary_scalar.right.operation
      assert_equal "`b` = +`c`", abs_unary_scalar.to_s
    end

    def test_conditions
      assert_equal "(`b` = 3) AND (`c` = 1)",
        SQLSearch.parse("b = 3 and c = 1").to_s
      assert_equal "(`b` = 3) OR (`c` = 1)",
        SQLSearch.parse("b = 3 or c = 1").to_s
      assert_equal "NOT (`b` = 3)",
        SQLSearch.parse("not (b = 3)").to_s
      assert_equal "NOT ((`b` = 3) AND (`c` <> 2))",
        SQLSearch.parse("not((b = 3) and (c <> 2))").to_s
      assert_equal "(`id` IN (1, 2, 3)) AND ((`state` = 'archived') OR (`created_at` > '2014-01-01T00:00:00+00:00'))",
        SQLSearch.parse("id in (1,2,3) and (state = 'archived' or created_at > '2014-01-01T00:00:00Z' )").to_s
    end
  end
end
