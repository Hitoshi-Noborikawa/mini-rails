# frozen_string_literal: true

module MiniRecord
  module Timestamp
    extend MiniSupport::Concern

    private

    def create_record
      set_timestamp_unless_present(:created_at)
      set_timestamp_unless_present(:updated_at)
      super
    end

    def update_record
      set_timestamp(:updated_at)
      super
    end

    def set_timestamp_unless_present(column)
      # t.timestamps を書いていないテーブルもあるため、実在するカラムだけを対象にする
      return unless timestamp_column?(column)
      # 明示的に日時がある場合は優先する
      return if public_send(column)

      set_timestamp(column)
    end

    def set_timestamp(column)
      return unless timestamp_column?(column)

      public_send("#{column}=", Time.now.to_s)
    end

    def timestamp_column?(column)
      self.class.column_names.include?(column.to_s)
    end
  end
end
