# frozen_string_literal: true

require_relative '../test_helper'

class PostsControllerTest < IntegrationTest
  test 'the top page lists posts newest first' do
    Post.create!(title: 'Older', created_at: '2026-08-01 10:00:00 +0900')
    Post.create!(title: 'Newer', created_at: '2026-08-02 10:00:00 +0900')

    get '/'

    assert_equal 200, last_response.status
    assert_operator last_response.body.index('Newer'), :<, last_response.body.index('Older')
  end

  test 'the index shows the comment count of each post' do
    post_record = Post.create!(title: 'Hello')
    post_record.comments.build(body: 'Nice').save!
    post_record.comments.build(body: 'Great').save!

    get '/posts'

    assert_includes last_response.body, 'コメント 2 件'
  end

  test 'the show page displays the body and comments' do
    post_record = Post.create!(title: 'Hello', body: 'World')
    post_record.comments.build(body: 'Nice').save!

    get "/posts/#{post_record.id}"

    assert_includes last_response.body, 'World'
    assert_includes last_response.body, 'Nice'
  end

  test 'the show page returns 404 for a missing post' do
    get '/posts/0'

    assert_equal 404, last_response.status
  end

  test 'creating a post redirects to it with a notice' do
    post '/posts', title: 'Hello', body: 'World'
    follow_redirect!

    assert_equal "/posts/#{Post.find_by!(title: 'Hello').id}", last_request.path
    assert_includes last_response.body, '投稿を作成しました'
  end

  test 'a blank title re-renders the form with errors' do
    post '/posts', title: '', body: 'World'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Title can't be blank"
    assert_equal 0, Post.count
  end

  test 'updating a post redirects to it with the new content' do
    post_record = Post.create!(title: 'Hello')

    post "/posts/#{post_record.id}", _method: 'patch', title: 'Bye', body: 'Updated'
    follow_redirect!

    assert_includes last_response.body, '投稿を更新しました'
    assert_includes last_response.body, 'Updated'
  end

  test 'destroying a post redirects to the index without it' do
    post_record = Post.create!(title: 'Hello')

    post "/posts/#{post_record.id}", _method: 'delete'
    follow_redirect!

    assert_equal '/posts', last_request.path
    assert_includes last_response.body, '投稿を削除しました'
    refute_includes last_response.body, 'Hello'
  end
end
