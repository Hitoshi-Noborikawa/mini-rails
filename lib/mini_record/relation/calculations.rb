# frozen_string_literal: true

module MiniRecord
  module Calculations
    def count
      sql, binds = build_sql(select: 'COUNT(*)', aggregate: true)
      @model_class.connection.execute(sql, *binds).first.first
    end

    def pluck(*column_names)
      names = column_names.map { validate_column!(_1) }
      sql, binds = build_sql(select: names.join(', '), aggregate: false)
      rows = @model_class.connection.execute(sql, *binds)
      names.size == 1 ? rows.map(&:first) : rows
    end
  end
end
