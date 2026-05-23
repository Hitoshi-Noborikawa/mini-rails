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

      # 実行済みの version 一覧を返す
      def all_versions
        Base.connection.execute("SELECT version FROM #{TABLE_NAME}").flatten
      end

      # version を実行済みとして記録
      def record!(version)
        Base.connection.execute(
          "INSERT INTO #{TABLE_NAME} (version) VALUES (?)",
          version
        )
      end
    end
  end
end
