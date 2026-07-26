# frozen_string_literal: true

class AddIndexToPostsPublished < MiniRecord::Migration
  def change
    add_index :posts, :published
  end
end
