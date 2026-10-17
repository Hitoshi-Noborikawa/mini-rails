# frozen_string_literal: true

require_relative '../test_helper'

# DDL is rolled back by the TestCase transaction too, so a dedicated table that doesn't clash with posts is used here
class MigrationTest < TestCase
  class CreateWidgets < MiniRecord::Migration
    def change
      create_table :widgets do |t|
        t.string :name
        t.integer :price
        t.timestamps
      end
    end
  end

  class AddColorToWidgets < MiniRecord::Migration
    def change
      add_column :widgets, :color, :string
    end
  end

  class RenameNameToLabel < MiniRecord::Migration
    def change
      rename_column :widgets, :name, :label
    end
  end

  class AddUniqueIndexToWidgets < MiniRecord::Migration
    def change
      add_index :widgets, :name, unique: true
    end
  end

  class RemovePriceFromWidgets < MiniRecord::Migration
    def change
      remove_column :widgets, :price, :integer
    end
  end

  class RemovePriceWithoutType < MiniRecord::Migration
    def change
      remove_column :widgets, :price
    end
  end

  class ChangeWidgets < MiniRecord::Migration
    def change
      change_table :widgets do |t|
        t.text :memo
        t.rename :name, :label
      end
    end
  end

  def setup
    super
    CreateWidgets.new.migrate(:up)
  end

  test 'create_table creates a table with id and the given columns' do
    assert_equal ['id', 'name', 'price', 'created_at', 'updated_at'], widget_columns
  end

  test 'create_table drops the table when migrated down' do
    CreateWidgets.new.migrate(:down)

    assert_empty widget_columns
  end

  test 'add_column adds the column up and removes it down' do
    AddColorToWidgets.new.migrate(:up)
    assert_includes widget_columns, 'color'

    AddColorToWidgets.new.migrate(:down)
    refute_includes widget_columns, 'color'
  end

  test 'rename_column restores the original name when migrated down' do
    RenameNameToLabel.new.migrate(:up)
    assert_includes widget_columns, 'label'

    RenameNameToLabel.new.migrate(:down)
    assert_includes widget_columns, 'name'
  end

  test 'add_index with unique: true rejects duplicate values' do
    AddUniqueIndexToWidgets.new.migrate(:up)
    connection.execute("INSERT INTO widgets (name) VALUES ('Bolt')")

    assert_raises(SQLite3::ConstraintException) do
      connection.execute("INSERT INTO widgets (name) VALUES ('Bolt')")
    end
  end

  test 'remove_column restores the column with its type when migrated down' do
    RemovePriceFromWidgets.new.migrate(:up)
    refute_includes widget_columns, 'price'

    RemovePriceFromWidgets.new.migrate(:down)
    assert_includes widget_columns, 'price'
  end

  test 'remove_column without a type cannot be migrated down' do
    RemovePriceWithoutType.new.migrate(:up)

    assert_raises(RuntimeError) { RemovePriceWithoutType.new.migrate(:down) }
  end

  test 'change_table can add and rename columns' do
    ChangeWidgets.new.migrate(:up)

    assert_equal ['id', 'label', 'price', 'created_at', 'updated_at', 'memo'], widget_columns
  end

  test 'a migration without change raises NotImplementedError' do
    assert_raises(NotImplementedError) { Class.new(MiniRecord::Migration).new.migrate(:up) }
  end

  private

  def connection
    MiniRecord::Base.connection
  end

  def widget_columns
    connection.execute('PRAGMA table_info(widgets)').map { _1[1] }
  end
end
