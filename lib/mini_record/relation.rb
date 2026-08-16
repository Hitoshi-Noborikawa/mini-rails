# frozen_string_literal: true

module MiniRecord
  class Relation
    include Enumerable
    include QueryMethods
    include FinderMethods
    include Calculations

    def initialize(model_class, values = {})
      @model_class = model_class
      @values = { conditions: {}, order: [], limit: nil }.merge(values)
      @records = nil
    end

    def build(attrs = {})
      @model_class.new(@conditions.merge(attrs))
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

    def build_sql(select: '*')
      sql = +"SELECT #{select} FROM #{@model_class.table_name}"
      binds = []

      unless conditions.empty?
        where_clauses = conditions.keys.map { "#{_1} = ?" }.join(' AND ')
        sql << " WHERE #{where_clauses} "
        binds.concat(conditions.values)
      end

      if select == '*'
        unless order_values.empty?
          order_clauses = order_values.map { |column, direction| "#{column} #{direction}" }.join(', ')
          sql << " ORDER BY #{order_clauses} "
        end

        sql << " LIMIT #{limit_value}" if limit_value
      end

      [sql, binds]
    end
  end
end
