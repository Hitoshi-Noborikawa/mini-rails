# frozen_string_literal: true

MiniRails.application.routes.draw do
  get '/', to: 'posts#index'
  resources :posts
  # TODO: Nested resources aren't supported yet, so only comment creation is defined
  post '/posts/:post_id/comments', to: 'comments#create'
end
