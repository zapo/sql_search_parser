require_relative '../../test_helper'

module SQLSearch
  class ParserTest < Minitest::Test

    def test_tokenizations
      {
        '' => [],
        ' ' => [],
        '  ' => [],
        '01.230' => [[:APPROXNUM, 1.23]],
        '01' => [[:INTNUM, 1]],
        "'2019-01-01T01:01:01-05:00'" => [[:TIME, DateTime.iso8601('2019-01-01T01:01:01-05:00')]],
        '"2019-01-01T01:01:01-05:00"' => [[:TIME, DateTime.iso8601('2019-01-01T01:01:01-05:00')]],
        "'test'" => [[:STRING, 'test']],
        '"test"' => [[:STRING, 'test']],
        '"with \"escaped\" quotes"' => [[:STRING, "with \\\"escaped\\\" quotes"]],
        "'2019-test'" => [[:STRING, '2019-test']],
        'in' => [[:IN, 'in']],
        'in_' => [[:NAME, 'in_']],
        'ini' => [[:NAME, 'ini']],
        'or' => [[:OR, 'or']],
        'or_' => [[:NAME, 'or_']],
        'oro' => [[:NAME, 'oro']],
        'and' => [[:AND, 'and']],
        'and_' => [[:NAME, 'and_']],
        'ando' => [[:NAME, 'ando']],
        'between' => [[:BETWEEN, 'between']],
        'between_' => [[:NAME, 'between_']],
        'betweeno' => [[:NAME, 'betweeno']],
        'like' => [[:LIKE, 'like']],
        'like_' => [[:NAME, 'like_']],
        'likeo' => [[:NAME, 'likeo']],
        '=' => [[:COMPARISON, '=']],
        '<=' => [[:COMPARISON, '<=']],
        '>=' => [[:COMPARISON, '>=']],
        '!=' => [[:COMPARISON, '!=']],
        '==' => [[:COMPARISON, '='], [:COMPARISON, '=']],
        'is' => [[:COMPARISON, 'is']],
        'is_' => [[:NAME, 'is_']],
        'isi' => [[:NAME, 'isi']],
        'is nothing' => [[:COMPARISON, 'is'], [:NAME, 'nothing']],
        'is not' => [[:COMPARISON, 'is not']],
        'not' => [[:NOT, 'not']],
        'not_' => [[:NAME, 'not_']],
        'noto' => [[:NAME, 'noto']],
        'null' => [[:NULL, nil]],
        'null_' => [[:NAME, 'null_']],
        'nullo' => [[:NAME, 'nullo']],
        'true' => [[:BOOL, true]],
        't' => [[:BOOL, true]],
        'false' => [[:BOOL, false]],
        'f' => [[:BOOL, false]],
        'a0b1' => [[:NAME, 'a0b1']],
        'a____b___' => [[:NAME, 'a____b___']],
        '__' => [[:NAME, '__']],
        '(' => [[:LPAREN, '(']],
        ')' => [[:RPAREN, ')']],
        '.' => [[:DOT, '.']],
        ',' => [[:COMMA, ',']],
        '+' => [[:ADD, '+']],
        '-' => [[:SUBTRACT, '-']],
        '/' => [[:DIVIDE, '/']],
        '*' => [[:MULTIPLY, '*']]
      }.each do |str, expected_tokens|
        assert_equal expected_tokens,
          SQLSearch.tokenize(str)
      end

      assert_raises(SQLSearch::Parser::ScanError) {
        SQLSearch.tokenize('0b')
      }
    end

    def test_comparisons
      assert_equal "`b` IS NULL",
        SQLSearch.parse("b is null").to_s
      assert_equal "`b` IS NOT NULL",
        SQLSearch.parse("b is not null").to_s
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
