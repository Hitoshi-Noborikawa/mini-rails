# frozen_string_literal: true

require_relative '../test_helper'

class InflectorTest < TestCase
  test 'pluralize appends s' do
    assert_equal 'posts', MiniSupport::Inflector.pluralize('post')
  end

  test 'singularize removes the trailing s' do
    assert_equal 'post', MiniSupport::Inflector.singularize('posts')
  end

  test 'singularize returns the word as is when it does not end with s' do
    assert_equal 'person', MiniSupport::Inflector.singularize('person')
  end

  test 'underscore converts CamelCase to snake_case' do
    assert_equal 'posts_controller', MiniSupport::Inflector.underscore('PostsController')
  end

  test 'underscore converts :: to /' do
    assert_equal 'active_model/errors', MiniSupport::Inflector.underscore('ActiveModel::Errors')
  end

  test 'underscore treats consecutive capitals as one acronym' do
    assert_equal 'xml_http_request', MiniSupport::Inflector.underscore('XMLHttpRequest')
  end

  test 'underscore does not mutate its argument' do
    word = +'PostsController'

    MiniSupport::Inflector.underscore(word)

    assert_equal 'PostsController', word
  end

  test 'camelize converts snake_case to CamelCase' do
    assert_equal 'PostsController', MiniSupport::Inflector.camelize('posts_controller')
  end

  test 'camelize converts / to ::' do
    assert_equal 'Admin::PostsController', MiniSupport::Inflector.camelize('admin/posts_controller')
  end

  test 'constantize returns the constant for a namespaced name' do
    assert_equal MiniSupport::Inflector, MiniSupport::Inflector.constantize('MiniSupport::Inflector')
  end

  test 'String methods delegate to Inflector' do
    assert_equal 'Post', 'posts'.singularize.camelize
  end
end
