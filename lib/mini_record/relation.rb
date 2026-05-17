# frozen_string_literal: true

module MiniRecord
  class Relation
    include Enumerable

    def initialize(model_class, conditions = {})
      @model_class = model_class
      @conditions = conditions
      @records = nil
    end

    def where(more_conditions)
      self.class.new(@model_class, @conditions.merge(more_conditions))
    end

    def each(&block)
      load!.each(&block)
    end

    def to_a
      load!
    end

    private

    def load!
      @records ||= begin
        sql, binds = build_sql
        @model_class.connection.execute(sql, *binds).map { @model_class.instantiate(_1) }
      end
    end

    def build_sql
      if @conditions.empty?
        ["SELECT * FROM #{@model_class.table_name}", []]
      else
        where_clauses = @conditions.keys.map { "#{_1} = ?" }.join(' AND ')
        sql = "SELECT * FROM #{@model_class.table_name} WHERE #{where_clauses}"
        [sql, @conditions.values]
      end
    end
  end
end
