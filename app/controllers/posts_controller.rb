# frozen_string_literal: true

class PostsController < MiniPack::Controller
  def index
    render plain: 'posts index'
  end

  def show
    render plain: "posts show id=#{params[:id]}"
  end

  def create
    redirect_to '/posts'
  end
end
