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
      @values = { where: WhereClause.new([]), order: [], limit: nil }.merge(values)
      @records = nil
    end

    def build(attrs = {})
      @model_class.new(where_clause.to_h.merge(attrs.transform_keys(&:to_s)))
    end

    def each(&block)
      load!.each(&block)
    end

    def to_a
      load!
    end

    def destroy_all
      to_a.each(&:destroy)
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

      unless where_clause.empty?
        sql << " WHERE #{where_clause.to_sql}"
        binds.concat(where_clause.binds)
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

    # Accessors keep raw @values[:xxx] lookups from spreading around
    # See: https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/relation/query_methods.rb#L162-L183
    def where_clause = @values[:where]
    def order_values = @values[:order]
    def limit_value = @values[:limit]
  end
end
