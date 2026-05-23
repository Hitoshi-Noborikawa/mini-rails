# frozen_string_literal: true

class CreatePosts < MiniRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.timestamps
    end
  end
end
