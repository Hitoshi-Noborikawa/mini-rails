# frozen_string_literal: true

require_relative '../test_helper'

class TimestampTest < TestCase
  test 'create sets created_at and updated_at' do
    post = Post.create!(title: 'Hello')

    refute_nil post.created_at
    refute_nil post.updated_at
  end

  test 'create keeps an explicitly given created_at' do
    post = Post.create!(title: 'Hello', created_at: '2026-08-01 10:00:00 +0900')

    assert_equal '2026-08-01 10:00:00 +0900', Post.find(post.id).created_at
  end

  test 'update changes only updated_at' do
    post = Post.create!(
      title: 'Hello',
      created_at: '2026-08-01 10:00:00 +0900',
      updated_at: '2026-08-01 10:00:00 +0900'
    )

    post.update(title: 'Bye')

    reloaded = Post.find(post.id)
    assert_equal '2026-08-01 10:00:00 +0900', reloaded.created_at
    refute_equal '2026-08-01 10:00:00 +0900', reloaded.updated_at
  end
end
