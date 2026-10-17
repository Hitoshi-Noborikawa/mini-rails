# frozen_string_literal: true

require_relative '../test_helper'

class AssociationsTest < TestCase
  test 'has_many returns a Relation filtered by the foreign key' do
    post = Post.create!(title: 'Hello')
    other_post = Post.create!(title: 'Other')
    comment = Comment.create!(post_id: post.id, body: 'Nice')
    Comment.create!(post_id: other_post.id, body: 'Other')

    assert_instance_of MiniRecord::Relation, post.comments
    assert_equal [comment.id], post.comments.map(&:id)
  end

  test 'build on a has_many Relation sets the foreign key' do
    post = Post.create!(title: 'Hello')

    comment = post.comments.build(body: 'Nice')

    assert_equal post.id, comment.post_id
    refute_predicate comment, :persisted?
  end

  test 'belongs_to returns the record the foreign key points to' do
    post = Post.create!(title: 'Hello')
    comment = Comment.create!(post_id: post.id, body: 'Nice')

    assert_equal post.id, comment.post.id
  end

  test 'belongs_to returns nil when the foreign key is nil' do
    assert_nil Comment.new(body: 'Nice').post
  end

  test 'the belongs_to writer sets the foreign key from a record' do
    post = Post.create!(title: 'Hello')
    comment = Comment.new(body: 'Nice')

    comment.post = post

    assert_equal post.id, comment.post_id
  end
end
