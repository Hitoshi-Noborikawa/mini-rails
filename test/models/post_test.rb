# frozen_string_literal: true

require_relative '../test_helper'

class PostTest < TestCase
  test 'strips surrounding whitespace from the title before saving' do
    post = Post.create!(title: '  Hello  ')

    assert_equal 'Hello', Post.find(post.id).title
  end

  test 'rejects a title used by another post' do
    Post.create!(title: 'Hello')
    post = Post.new(title: 'Hello')

    assert_predicate post, :invalid?
    assert_equal ['has already been taken'], post.errors[:title]
  end

  test 'rejects a title that matches another post after stripping' do
    Post.create!(title: 'Hello')

    assert_predicate Post.new(title: ' Hello '), :invalid?
  end

  test 'can be updated while keeping its own title' do
    post = Post.create!(title: 'Hello')

    assert post.update(body: 'Updated')
  end
end
