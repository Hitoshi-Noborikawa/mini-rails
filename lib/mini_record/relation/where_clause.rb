# frozen_string_literal: true

module MiniRecord
  class Relation
    class WhereClause
      # NOTE: Arel は未実装なので最小構成にしている
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

      # NOTE: WhereCaluse は Arel ノードを返すだけで、本来ここは Arel の visitor で行うが、
      # 現状 Arel を入れていないので、一旦ここで行っている。
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
