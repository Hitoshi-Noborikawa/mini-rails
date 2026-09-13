# frozen_string_literal: true

module MiniRecord
  class Relation
    class Predicate
      attr_reader :column, :operator, :value

      def initialize(column, operator, value)
        @column = column
        @operator = operator
        @value = value
      end

      def equality?
        operator == :eq
      end

      def to_sql
        case operator
        when :eq
          "#{column} = ?"
        when :is_null
          "#{column} IS NULL"
        when :in
          value.empty? ? '1=0' : "#{column} IN (#{(['?'] * value.size).join(', ')})"
        when :between
          "#{column} BETWEEN ? AND ?"
        when :gteq_lt
          "#{column} >= ? AND #{column} < ?"
        end
      end

      def binds
        case operator
        when :eq
          [value]
        when :is_null
          []
        when :in
          value
        when :between, :gteq_lt
          [value.first, value.last]
        end
      end
    end
  end
end
