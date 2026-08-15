# frozen_string_literal: true

module Mini_Record
  module ModelSchema
    extend MiniSupport::Concern

    class_methods do
      def table_name
        # name は Class#name で、クラス名の文字列を返す
        name.underscore.pluralize
      end

      # PRAGMA table_info(posts) で columns 情報を取得
      # 返り値は [cid, name, type, notnull, dfit_value, pk]
      # 今回は name だけ使う
      def column_names
        @column_names ||= connection.execute("PRAGMA table_info(#{table_name})").map { _1[1] }
      end
    end
  end
end
