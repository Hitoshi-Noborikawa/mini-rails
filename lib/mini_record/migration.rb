# frozen_string_literal: true

module MiniRecord
  class Migration
    def migrate
      change
    end

    # テンプレートメソッドパターン（説明しようか迷いどころ）
    def change
      raise NotImplementedError, "#{self.class} must implement #change"
    end

    def create_table(table_name, &block)
      definition = TableDefinition.new(table_name)
      yield definition # block の中で t.string :title などが呼ばれる
      Base.connection.execute(definition.to_sql)
    end
  end

  class TableDefinition
    attr_reader :columns

    def initialize(table_name)
      @table_name = table_name
      @columns = []
    end

    def string(name)
      @columns << "#{name} TEXT"
    end

    # SQLite は TEXT 型に文字列も text も格納可能 なので同じにしている
    def text(name)
      @columns << "#{name} TEXT"
    end

    def integer(name)
      @columns << "#{name} INTEGER"
    end

    def timestamps
      @columns << 'created_at TEXT'
      @columns << 'updated_at TEXT'
    end

    def to_sql
      <<~SQL
        CREATE TABLE #{@table_name} (
          id INTEGER PRIMARY KEY,
          #{@columns.join(",\n ")}
        );
      SQL
    end
  end
end
