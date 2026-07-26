# frozen_string_literal: true

class AddPublishedToPosts < MiniRecord::Migration
  def change
    add_column :posts, :published, :integer
  end
end
