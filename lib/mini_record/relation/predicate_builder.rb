# frozen_string_literal: true

module MiniRecord
  class PredicateBuilder
    def self.build(column, value)
      value = value.id if value.respond_to?(:id)

      case value
      when nil
        Relation::Predicate.new(column, :is_null, value)
      when Array
        Relation::Predicate.new(column, :in, value)
      when Range
        range_predicate(column, value)
      else
        Relation::Predicate.new(column, :eq, value)
      end
    end

    def self.range_predicate(column, range)
      operator = range.exclude_end? ? :gteq_lt : :between
      Relation::Predicate.new(column, operator, range)
    end
  end
end
