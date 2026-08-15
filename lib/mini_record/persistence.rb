# frozen_string_literal: true

module MiniRecord
  module Persistence
    extend MiniSupport::Concern

    def save
      return false unless valid?

      run_callbacks(:save) do
        if persisted?
          run_callbacks(:update) { update_record }
        else
          run_callbacks(:create) { create_record }
        end
      end
    end

    def save!
      # raise_validation_error を参考。今は RecordNotSaved は気にしない
      # https://github.com/rails/rails/blob/c0c715b66e98dee1436f06ef682c42ab1de0c7e1/activerecord/lib/active_record/validations.rb#L87
      save || raise(RecordInvalid, self)
    end

    def update(attrs)
      attrs.each { |k, v| send("#{k}=", v) }
      save
    end

    def destroy
      return false unless persisted?

      self.class.connection.execute(
        "DELETE FROM #{self.class.table_name} WHERE id = ?",
        id
      )
      @persisted = false
      true
    end

    private

    def create_record
      names = self.class.column_names - ['id'] # 例: ['title', 'body', 'created_at', 'updated_at']
      values = names.map { send(_1) } # 例: ['Hello', 'World', nil, nil]
      placeholders = (['?'] * names.size).join(', ') # '?, ?, ?, ?'
      # 生成される SQL の例: INSERT INTO posts (title, body, created_at, updated_at) VALUES (?, ?, ?, ?)
      # バインド引数: 'Hello', 'World', nil, nil
      self.class.connection.execute(
        "INSERT INTO #{self.class.table_name} (#{names.join(', ')}) VALUES (#{placeholders})",
        *values
      )
      self.id = self.class.connection.last_insert_row_id
      @persisted = true
      true
    end

    def update_record
      names = self.class.column_names - ['id']
      values = names.map { send(_1) }
      set_clause = names.map { "#{_1} = ?" }.join(', ')
      self.class.connection.execute(
        "UPDATE #{self.class.table_name} SET #{set_clause} WHERE id = ?",
        *values, id
      )
      true
    end
  end
end
