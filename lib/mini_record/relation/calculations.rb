# frozen_string_literal: true

module MiniRecord
  module Calculations
    def count
      sql, binds = build_sql(select: 'COUNT(*)')
      @model_class.connection.execute(sql, *binds).first.first
    end
  end
end
