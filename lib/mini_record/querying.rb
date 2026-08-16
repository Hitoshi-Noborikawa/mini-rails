# frozen_string_literal: true

module MiniRecord
  module Querying
    QUERYING_METHODS = %i[find where].freeze

    extend MiniSupport::Concern

    class_methods do
      # delegate(*QUERYING_METHODS, to: :all) したいが、まだ作っていないので define_method している
      # https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/querying.rb#L5-L24
      QUERYING_METHODS.each do |name|
        define_method(name) { |*args, &block| all.public_send(name, *args, &block) }
      end

      # ここも ActiveRecord::Scoping::Named#all をまだ作っていないので一旦これで対応
      def all
        Relation.new(self)
      end

      VALID_DIRECTIONS = [:asc, :desc, :ASC, :DESC, 'asc', 'desc', 'ASC', 'DESC'].to_set.freeze

      def order(*args)
        spawn(order: @values[:order] + args.flat_map { normalize_order(_1) })
      end

      def reverse_order
        spawn(order: reverse_sql_order(order_values))
      end

      def limit(value)
        spawn(limit: Integer(value))
      end

      def first
        ordered_relation.limit(1).to_a.first
      end

      def last
        # Post.limit(3).last に対応するため。reverse してしまうと異なる結果を返してしまう
        return to_a.last if limit_value

        reverse_order.limit(1).to_a.first
      end

      def count
        sql, binds = build_sql(select: 'COUNT(*)')
        @model_class.connection.execute(sql, *binds).first.first
      end

      private

      def ordered_relation
        order_values.empty? ? order(:id) : self
      end

      def reverse_sql_order(order_values)
        return [['id', 'DESC']] if order_values.empty?

        order_values.map { |column, direction| [column, direction == 'ASC' ? 'DESC' : 'ASC'] }
      end

      # @values[:xxx] を直接書くと散らばるので accessor を用意しておく
      # 参考: https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/relation/query_methods.rb#L162-L183
      def conditions = @values[:conditions]
      def order_values = @values[:order]
      def limit_value = @values[:limit]

      def normalize_order(arg)
        case arg
        when Symbol, String
          [[validate_column!(arg), 'ASC']]
        when Hash
          arg.map { |column, direction| [validate_column!(column), validate_direction!(direction)] }
        else
          raise ArgumentError, "unsupported order argument: #{arg.inspect}"
        end
      end

      def validate_column!(column)
        name = column.to_s
        return name if @model_class.column_names.include?(name)

        raise ArgumentError, "unknown column: #{name}"
      end

      def validate_direction!(direction)
        return direction.to_s.upcase if VALID_DIRECTIONS.include?(direction)

        raise ArgumentError, "Direction \"#{direction}\" is invalid. Value directions are: #{VALID_DIRECTIONS.to_s.inspect}"
      end
    end
  end
end
