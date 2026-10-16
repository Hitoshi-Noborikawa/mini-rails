# frozen_string_literal: true

module MiniRecord
  class SchemaMigration
    TABLE_NAME = 'schema_migrations'

    class << self
      def ensure_table!
        Base.connection.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS #{TABLE_NAME} (
            version TEXT PRIMARY KEY
          );
        SQL
      end

      def all_versions
        Base.connection.execute("SELECT version FROM #{TABLE_NAME}").flatten
      end

      def record!(version)
        Base.connection.execute(
          "INSERT INTO #{TABLE_NAME} (version) VALUES (?)",
          version
        )
      end

      def remove!(version)
        Base.connection.execute(
          "DELETE FROM #{TABLE_NAME} WHERE version = ?",
          version
        )
      end
    end
  end
end
