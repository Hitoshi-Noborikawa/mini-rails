# frozen_string_literal: true

require_relative '../test_helper'

class ResourcesTest < TestCase
  include MiniPack::UrlHelpers

  test 'resources defines routes for the seven actions' do
    routes = []

    MiniPack::Mapper.new(routes).resources(:photos)

    assert_equal [
      [:get, '/photos', 'index'],
      [:get, '/photos/new', 'new'],
      [:post, '/photos', 'create'],
      [:get, '/photos/:id', 'show'],
      [:get, '/photos/:id/edit', 'edit'],
      [:patch, '/photos/:id', 'update'],
      [:delete, '/photos/:id', 'destroy']
    ], routes.map { [_1.method, _1.pattern, _1.action] }
  end

  test 'resources defines named route helpers' do
    MiniPack::Mapper.new([]).resources(:photos)

    assert_equal '/photos', photos_path
    assert_equal '/photos/new', new_photo_path
    assert_equal '/photos/1', photo_path(1)
    assert_equal '/photos/1/edit', edit_photo_path(1)
  end

  test 'resource defines routes for six actions without an id' do
    routes = []

    MiniPack::Mapper.new(routes).resource(:profile)

    assert_equal [
      [:get, '/profile/new', 'new'],
      [:post, '/profile', 'create'],
      [:get, '/profile', 'show'],
      [:get, '/profile/edit', 'edit'],
      [:patch, '/profile', 'update'],
      [:delete, '/profile', 'destroy']
    ], routes.map { [_1.method, _1.pattern, _1.action] }
  end

  test 'resource defines named route helpers without an id' do
    MiniPack::Mapper.new([]).resource(:profile)

    assert_equal '/profile', profile_path
    assert_equal '/profile/new', new_profile_path
    assert_equal '/profile/edit', edit_profile_path
  end
end
