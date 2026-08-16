# frozen_string_literal: true

module MiniRecord
  class Relation
    include Enumerable

    def initialize(model_class, values = {})
      @model_class = model_class
      @values = { conditions: {}, order: [], limit: nil }.merge(values)
      @records = nil
    end

    def build(attrs = {})
      @model_class.new(@conditions.merge(attrs))
    end

    def where(more_conditions)
      spawn(conditions: @values[:conditions].merge(more_conditions))
    end

    def find(*args, &block)
      return super if block
      raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 1)" unless args.size == 1

      id = args.first
      record = where(id: id).to_a.first
      raise RecordNotFound, "#{@model_class.name} not found: id=#{id}" unless record

      record
    end

    def each(&block)
      load!.each(&block)
    end

    def to_a
      load!
    end

    private

    def spawn(new_values)
      self.class.new(@model_class, @values.merge(new_values))
    end

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
