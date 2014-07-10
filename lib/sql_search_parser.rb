module SQLSearch

  def self.parse input
    SQLSearch::Parser.new.parse(input)
  end

  module Conditions
    class Base ;end
    class And < Base
      attr_reader :left, :right
      def initialize options
        @left = options[:left]; @right = options[:right]
      end

      def to_s
        "(#{left}) AND (#{right})"
      end
    end

    class Or < Base
      attr_reader :left, :right
      def initialize options
        @left = options[:left]; @right = options[:right]
      end

      def to_s
        "(#{left}) OR (#{right})"
      end
    end

    class Not < Base
      attr_reader :value
      def initialize options
        @value = options[:value]
      end

      def to_s
        "NOT (#{value})"
      end
    end
  end

  module Comparisons
    class Base
      attr_reader :left, :right, :operator

      def initialize options
        @left = options[:left]
        @right = options[:right]
        @operator = options[:operator]
      end

      def to_s
        "#{left} #{operator} #{right}"
      end
    end

    class In < Base
      def initialize options
        super options
        @operator = :IN
      end
    end
  end

  module Atoms
    class Base; end
    class InValues < Base
      attr_reader :values
      def initialize options
        @values = options[:values]
      end

      def to_s
        "(#{values.join(', ')})"
      end
    end

    class Scalar < Base
      attr_reader :left, :right, :operation
      def initialize options
        @left = options[:left]
        @right = options[:right]
        @operation = options[:operation]
      end

      def to_s
        "#{left} #{operation} #{right}"
      end
    end

    class UnaryScalar < Scalar
      attr_reader :value, :operation
      def initialize options
        @value = options[:value]
        @operation = options[:operation]
      end

      def to_s
        "#{operation}#{value}"
      end
    end

    class Literal < Base
      attr_reader :value, :type
      def initialize options
        @value = options[:value]
        @type = options[:type]
      end

      def to_s
        case type
        when :string, :datetime
          "'#{value}'"
        when :boolean
          value == true ? 'TRUE' : 'FALSE'
        else
          "#{value}"
        end
      end
    end

    class Column < Base
      attr_reader :name, :space

      def initialize options
        @name = options[:name]
        @space = options[:space]
      end

      def to_s
        [space,name].compact.map { |a| "`#{a}`" }.join('.')
      end
    end
  end
end

require 'sql_search/parser.racc.rb'
