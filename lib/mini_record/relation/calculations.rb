# frozen_string_literal: true

module MiniRecord
  module Calculations
    # FIXME: limit is ignored. Post.limit(2).count returns the total count, not 2 (SELECT COUNT(*) ... LIMIT 2)
    # Wrapping it in a subquery when has_limit_or_offset? should fix it (offset needs adding too)
    # https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/relation/calculations.rb#L668-L689
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
