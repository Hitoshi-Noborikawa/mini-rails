# frozen_string_literal: true

class CreateComments < MiniRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :post_id
      t.text :body
      t.timestamps
    end
  end
end
