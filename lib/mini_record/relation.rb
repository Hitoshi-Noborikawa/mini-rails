# frozen_string_literal: true

module MiniRecord
  class Relation
    include Enumerable
    include SpawnMethods
    include QueryMethods
    include FinderMethods
    include Calculations

    def initialize(model_class, values = {})
      @model_class = model_class
      @values = { conditions: {}, order: [], limit: nil }.merge(values)
      @records = nil
    end

    def build(attrs = {})
      @model_class.new(conditions.merge(attrs))
    end

    def each(&block)
      load!.each(&block)
    end

    def to_a
      load!
    end

    private

    def validate_column!(column)
      name = column.to_s
      return name if @model_class.column_names.include?(name)

      raise ArgumentError, "unknown column: #{name}"
    end

    def load!
      @records ||= begin
        sql, binds = build_sql
        @model_class.connection.execute(sql, *binds).map { @model_class.instantiate(_1) }
      end
    end

    def build_sql(select: '*', aggregate: false)
      sql = +"SELECT #{select} FROM #{@model_class.table_name}"
      binds = []

      unless conditions.empty?
        where_clauses = conditions.keys.map { "#{_1} = ?" }.join(' AND ')
        sql << " WHERE #{where_clauses}"
        binds.concat(conditions.values)
      end

      unless aggregate
        unless order_values.empty?
          order_clauses = order_values.map { |column, direction| "#{column} #{direction}" }.join(', ')
          sql << " ORDER BY #{order_clauses}"
        end

        sql << " LIMIT #{limit_value}" if limit_value
      end

      [sql, binds]
    end

    # @values[:xxx] を直接書くと散らばるので accessor を用意しておく
    # 参考: https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/relation/query_methods.rb#L162-L183
    def conditions = @values[:conditions]
    def order_values = @values[:order]
    def limit_value = @values[:limit]
  end
end
