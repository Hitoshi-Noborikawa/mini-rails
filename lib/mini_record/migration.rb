# frozen_string_literal: true

module MiniRecord
  class Migration
    def migrate(direction)
      @direction = direction
      change
    end

    # Template method pattern (not sure yet whether to explain it)
    def change
      raise NotImplementedError, "#{self.class} must implement #change"
    end

    def create_table(table_name, &block)
      if @direction == :down
        Base.connection.execute("DROP TABLE #{table_name};")
      else
        definition = TableDefinition.new(table_name)
        yield definition # t.string :title etc. are called inside the block
        Base.connection.execute(definition.to_sql)
      end
    end

    def add_column(table_name, column_name, type)
      if @direction == :down
        Base.connection.execute("ALTER TABLE #{table_name} DROP COLUMN #{column_name};")
      else
        sql_type = TableDefinition.sql_type_for(type)
        Base.connection.execute("ALTER TABLE #{table_name} ADD COLUMN #{column_name} #{sql_type};")
      end
    end

    def remove_column(table_name, column_name, type = nil)
      if @direction == :down
        raise "remove_column requires a type to be reversible: remove_column :#{table_name}, :#{column_name}, :string" if type.nil?

        sql_type = TableDefinition.sql_type_for(type)
        Base.connection.execute("ALTER TABLE #{table_name} ADD COLUMN #{column_name} #{sql_type};")
      else
        Base.connection.execute("ALTER TABLE #{table_name} DROP COLUMN #{column_name};")
      end
    end

    def rename_column(table_name, old_name, new_name)
      from, to = if @direction == :down
                   [new_name, old_name]
                 else
                   [old_name, new_name]
                 end

      Base.connection.execute("ALTER TABLE #{table_name} RENAME COLUMN #{from} TO #{to};")
    end

    def add_index(table_name, column_name, unique: false)
      index_name = index_name_for(table_name, column_name)

      if @direction == :down
        Base.connection.execute("DROP INDEX #{index_name};")
      else
        unique_sql = unique ? 'UNIQUE ' : ''
        Base.connection.execute("CREATE #{unique_sql}INDEX #{index_name} ON #{table_name} (#{column_name});")
      end
    end

    def remove_index(table_name, column_name)
      index_name = index_name_for(table_name, column_name)

      if @direction == :down
        raise 'remove_index requires the original column to rebuild the index -- not implemented (out of scope)'
      else
        Base.connection.execute("DROP INDEX #{index_name};")
      end
    end

    def change_table(table_name, &block)
      yield ChangeTableProxy.new(self, table_name)
    end

    private

    def index_name_for(table_name, column_name)
      "index_#{table_name}_on_#{column_name}"
    end
  end

  # Wrapper that allows calls like t.string :name inside a change_table block
  class ChangeTableProxy
    def initialize(migration, table_name)
      @migration = migration
      @table_name = table_name
    end

    def string(name)
      @migration.add_column(@table_name, name, :string)
    end

    def text(name)
      @migration.add_column(@table_name, name, :text)
    end

    def integer(name)
      @migration.add_column(@table_name, name, :integer)
    end

    def remove(name)
      @migration.remove_column(@table_name, name)
    end

    def rename(old_name, new_name)
      @migration.rename_column(@table_name, old_name, new_name)
    end

    def index(column_name, **options)
      @migration.add_index(@table_name, column_name, **options)
    end
  end
end
