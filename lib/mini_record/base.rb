# frozen_string_literal: true

module MiniRecord
  class RecordNotFound < StandardError; end

  class Base
    include MiniModel::Validations
    include MiniRecord::Associations

    define_callbacks :save, :create, :update

    @@connection = nil

    def initialize(attrs = {})
      self.class.setup_attribute_methods!
      @persisted = false
      attrs.each { |k, v| send("#{k}=", v) }
    end

    def persisted?
      @persisted
    end

    def save
      return false unless valid?

      run_callbacks(:save) do
        if persisted?
          run_callbacks(:update) { update_record }
        else
          run_callbacks(:create) { insert_record }
        end
      end
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

    def insert_record
      cols = self.class.columns - ['id'] # 例: ['title', 'body', 'created_at', 'updated_at']
      values = cols.map { send(_1) } # 例: ['Hello', 'World', nil, nil]
      placeholders = (['?'] * cols.size).join(', ') # '?, ?, ?, ?'
      # 生成される SQL の例: INSERT INTO posts (title, body, created_at, updated_at) VALUES (?, ?, ?, ?)
      # バインド引数: 'Hello', 'World', nil, nil
      self.class.connection.execute(
        "INSERT INTO #{self.class.table_name} (#{cols.join(', ')}) VALUES (#{placeholders})",
        *values
      )
      self.id = self.class.connection.last_insert_row_id
      @persisted = true
      true
    end

    def update_record
      cols = self.class.columns - ['id']
      values = cols.map { send(_1) }
      set_clause = cols.map { "#{_1} = ?" }.join(', ')
      self.class.connection.execute(
        "UPDATE #{self.class.table_name} SET #{set_clause} WHERE id = ?",
        *values, id
      )
      true
    end

    class << self
      def establish_connection(database_path)
        @@connection = Connection.new(database_path)
      end

      def connection
        @@connection
      end

      def table_name
        # name は Class#name で、クラス名の文字列を返す
        name.underscore.pluralize
      end

      # PRAGMA table_info(posts) で columns 情報を取得
      # 返り値は [cid, name, type, notnull, dfit_value, pk]
      # 今回は name だけ使う
      def columns
        @columns ||= connection.execute("PRAGMA table_info(#{table_name})").map { _1[1] }
      end

      # 初回呼び出し時に1度だけ実行。columns から動的に attribute accessors を生やす
      def setup_attribute_methods!
        return if @attribute_methods_set

        columns.each do |col|
          define_method(col)       { instance_variable_get("@#{col}") }
          define_method("#{col}=") { instance_variable_set("@#{col}", _1) }
        end

        @attribute_methods_set = true
      end

      # DB から取り出した row を Model のインスタンスに変換する
      def instantiate(row)
        setup_attribute_methods!
        # columns: ['id', 'title', 'body', ...]
        # row    : [1, 'Hello', 'World', ...]
        # => {'id' => 1, 'title' => 'Hello', ...}
        attrs = columns.zip(row).to_h
        instance = new(attrs)
        instance.instance_variable_set(:@persisted, true)
        instance
      end

      def find(id)
        rows = connection.execute(
          "SELECT * FROM #{table_name} WHERE id = ? LIMIT 1",
          id
        )
        raise RecordNotFound, "#{name} not found: id=#{id}" if rows.empty?

        instantiate(rows.first)
      end

      def all
        Relation.new(self)
      end

      def where(conditions)
        Relation.new(self, conditions)
      end

      def create(attrs)
        new(attrs).tap(&:save)
      end
    end
  end
end
