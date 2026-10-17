# frozen_string_literal: true

require_relative '../test_helper'

class PersistenceTest < TestCase
  test 'create assigns an id and the record can be reloaded' do
    post = Post.create(title: 'Hello', body: 'World')

    assert_predicate post, :persisted?
    assert_equal 'World', Post.find(post.id).body
  end

  test 'create returns an unsaved instance when validation fails' do
    post = Post.create(title: '')

    refute_predicate post, :persisted?
    assert_nil post.id
    assert_equal 0, Post.count
  end

  test 'create! raises RecordInvalid when validation fails' do
    error = assert_raises(MiniRecord::RecordInvalid) { Post.create!(title: '') }

    assert_equal "Title can't be blank", error.message
    assert_instance_of Post, error.record
  end

  test 'save on a persisted record updates instead of inserting' do
    post = Post.create!(title: 'Hello')
    post.body = 'Updated'

    post.save

    assert_equal 1, Post.count
    assert_equal 'Updated', Post.find(post.id).body
  end

  test 'update assigns attributes and saves' do
    post = Post.create!(title: 'Hello')

    assert post.update(title: 'Bye')
    assert_equal 'Bye', Post.find(post.id).title
  end

  test 'update returns false and leaves the DB unchanged when validation fails' do
    post = Post.create!(title: 'Hello')

    refute post.update(title: '')
    assert_equal 'Hello', Post.find(post.id).title
  end

  test 'destroy deletes the row and makes persisted? false' do
    post = Post.create!(title: 'Hello')

    assert post.destroy
    refute_predicate post, :persisted?
    refute Post.where(id: post.id).exists?
  end

  test 'destroy returns false for a new record' do
    refute Post.new(title: 'Hello').destroy
  end
end
