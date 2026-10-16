# frozen_string_literal: true

MiniRails.application.routes.draw do
  get '/', to: 'posts#index'
  resources :posts
  # TODO: resources のネストは未対応なので、コメント作成だけ定義している
  post '/posts/:post_id/comments', to: 'comments#create'
end
