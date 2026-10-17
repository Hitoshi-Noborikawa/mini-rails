# frozen_string_literal: true

module MiniRecord
  class Relation
    class WhereClause
      # NOTE: Arel isn't implemented, so this is kept minimal
      def initialize(predicates)
        @predicates = predicates
      end

      def +(other)
        WhereClause.new(predicates + other.predicates)
      end

      def empty?
        predicates.empty?
      end

      def to_h
        predicates.select(&:equality?).to_h do |predicate|
          [predicate.column, predicate.value]
        end
      end

      # NOTE: In Rails, WhereClause only returns Arel nodes and an Arel visitor builds the SQL.
      # There is no Arel here yet, so the SQL is built here for now.
      def to_sql
        predicates.map(&:to_sql).join(' AND ')
      end

      def binds
        predicates.flat_map(&:binds)
      end

      protected

      attr_reader :predicates
    end
  end
end
