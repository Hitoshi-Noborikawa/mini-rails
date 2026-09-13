# frozen_string_literal: true

MiniRails.application.routes.draw do
  get '/', to: 'posts#index'
  resources :posts
end
