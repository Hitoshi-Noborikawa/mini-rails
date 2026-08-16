# frozen_string_literal: true

module MiniRecord
  module Calculations
    # FIXME: limit が無視される。Post.limit(2).count は 2 ではなく全件数を返す（SELECT COUNT(*) ... LIMIT 2）
    # has_limit_or_offset? のときサブクエリで包めば良さそう。（offset も追加しないと）
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
