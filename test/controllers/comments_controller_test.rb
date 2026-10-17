# frozen_string_literal: true

require_relative '../test_helper'

class CommentsControllerTest < IntegrationTest
  test 'posting a comment shows it on the post page' do
    post_record = Post.create!(title: 'Hello')

    post "/posts/#{post_record.id}/comments", body: 'Nice'
    follow_redirect!

    assert_equal "/posts/#{post_record.id}", last_request.path
    assert_includes last_response.body, 'コメントを投稿しました'
    assert_includes last_response.body, 'Nice'
  end

  test 'a blank comment is not saved and shows an alert' do
    post_record = Post.create!(title: 'Hello')

    post "/posts/#{post_record.id}/comments", body: ''
    follow_redirect!

    assert_includes last_response.body, 'コメントを入力してください'
    assert_equal 0, Comment.count
  end
end
