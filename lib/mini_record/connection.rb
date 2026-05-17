# frozen_string_literal: true

require 'sqlite3'

module MiniRecord
  class Connection
    def initialize(database_path)
      @db = SQLite3::Database.new(database_path)
    end

    def execute(sql, *binds)
      @db.execute(sql, *binds)
    end

    def last_insert_row_id
      @db.last_insert_row_id
    end
  end
end
