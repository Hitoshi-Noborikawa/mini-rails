# frozen_string_literal: true

module MiniRecord
  module QueryMethods
    def where(more_conditions)
      spawn(conditions: @values[:conditions].merge(more_conditions))
    end

    def order(*args)
      spawn(order: @values[:order] + args.flat_map { normalize_order(_1) })
    end

    def limit(value)
      spawn(limit: Integer(value))
    end

    def reverse_order
      spawn(order: reverse_sql_order(order_values))
    end

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

    VALID_DIRECTIONS = [:asc, :desc, :ASC, :DESC, 'asc', 'desc', 'ASC', 'DESC'].to_set.freeze

    def validate_direction!(direction)
      return direction.to_s.upcase if VALID_DIRECTIONS.include?(direction)

      raise ArgumentError, "Direction \"#{direction}\" is invalid. Value directions are: #{VALID_DIRECTIONS.to_s.inspect}"
    end

    def reverse_sql_order(order_values)
      return [['id', 'DESC']] if order_values.empty?

      order_values.map { |column, direction| [column, direction == 'ASC' ? 'DESC' : 'ASC'] }
    end
  end
end
