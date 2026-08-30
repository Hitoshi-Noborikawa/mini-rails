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
        # TODO: IN や BETWEEN を追加した際は to_h する条件を = だけに絞る。
        # id IN (1, 2) という条件では絞れないため。
        predicates.to_h do |column, _operator, value|
          [column, value]
        end
      end

      # NOTE: WhereCaluse は Arel ノードを返すだけで、本来ここは Arel の visitor で行うが、
      # 現状 Arel を入れていないので、一旦ここで行っている。
      def to_sql
        # TODO: ? は SQLite の方言なので別の DB 加えるときに剥がす
        predicates.map do |column, operator, _value|
          "#{column} #{operator} ?"
        end.join(' AND ')
      end

      def binds
        predicates.map(&:last)
      end

      protected

      attr_reader :predicates
    end
  end
end
