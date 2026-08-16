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
