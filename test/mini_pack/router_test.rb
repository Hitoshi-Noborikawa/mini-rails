# frozen_string_literal: true

require_relative '../test_helper'

class RouterTest < TestCase
  include Rack::Test::Methods

  # Router constantizes 'router_test/items' into RouterTest::ItemsController
  class ItemsController < MiniPack::Controller
    def index
      render plain: 'index'
    end

    def show
      render plain: "show #{params[:id]} #{params[:id].encoding}"
    end

    def update
      render plain: 'update'
    end

    def fresh
      render plain: 'fresh'
    end

    def missing
      Post.find(0)
    end
  end

  def app
    @app ||= MiniPack::Router.new.tap do |router|
      router.draw do
        get '/items', to: 'router_test/items#index'
        get '/items/fresh', to: 'router_test/items#fresh'
        get '/items/missing', to: 'router_test/items#missing'
        get '/items/:id', to: 'router_test/items#show'
        patch '/items/:id', to: 'router_test/items#update'
      end
    end
  end

  test 'dispatches to the route matching the HTTP method and path' do
    get '/items'

    assert_equal 200, last_response.status
    assert_equal 'index', last_response.body
  end

  test 'puts :id from the path into params as a UTF-8 String' do
    get '/items/42'

    assert_equal 'show 42 UTF-8', last_response.body
  end

  test 'the route registered first wins' do
    get '/items/fresh'

    assert_equal 'fresh', last_response.body
  end

  test 'returns 404 when no route matches' do
    get '/unknown'

    assert_equal 404, last_response.status
  end

  test 'returns 404 when the path matches but the HTTP method does not' do
    delete '/items/42'

    assert_equal 404, last_response.status
  end

  test 'treats a POST with _method as that HTTP method' do
    post '/items/42', _method: 'PATCH'

    assert_equal 'update', last_response.body
  end

  test 'returns 404 when the action raises RecordNotFound' do
    get '/items/missing'

    assert_equal 404, last_response.status
  end
end
