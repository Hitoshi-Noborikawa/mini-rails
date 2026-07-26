# frozen_string_literal: true

module MiniRecord
  class TableDefinition
    attr_reader :columns

    def initialize(table_name)
      @table_name = table_name
      @columns = []
    end

    def string(name)
      @columns << "#{name} #{self.class.sql_type_for(:string)}"
    end

    def text(name)
      @columns << "#{name} #{self.class.sql_type_for(:text)}"
    end

    def integer(name)
      @columns << "#{name} #{self.class.sql_type_for(:integer)}"
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

    def self.sql_type_for(type)
      case type
      when :string, :text
        'TEXT'
      when :integer
        'INTEGER'
      else
        raise ArgumentError, "unsupported column type: #{type}"
      end
    end
  end
end
