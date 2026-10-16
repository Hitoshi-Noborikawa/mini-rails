# frozen_string_literal: true

module MiniRecord
  module Persistence
    extend MiniSupport::Concern

    class_methods do
      # DB から取り出した row を Model のインスタンスに変換する
      def instantiate(row)
        setup_attribute_methods!
        # column_names: ['id', 'title', 'body', ...]
        # row         : [1, 'Hello', 'World', ...]
        # => {'id' => 1, 'title' => 'Hello', ...}
        attrs = column_names.zip(row).to_h
        instance = new(attrs)
        instance.instance_variable_set(:@persisted, true)
        instance
      end

      def create(attrs)
        new(attrs).tap(&:save)
      end

      def create!(attrs)
        new(attrs).tap(&:save!)
      end
    end

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
      names = self.class.column_names - ['id']
      values = names.map { public_send(_1) }
      placeholders = (['?'] * names.size).join(', ')
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
      values = names.map { public_send(_1) }
      set_clause = names.map { "#{_1} = ?" }.join(', ')
      self.class.connection.execute(
        "UPDATE #{self.class.table_name} SET #{set_clause} WHERE id = ?",
        *values, id
      )
      true
    end
  end
end
