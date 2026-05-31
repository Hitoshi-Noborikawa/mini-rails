# frozen_string_literal: true

class PostsController < MiniPack::Controller
  def index
    @posts = Post.all.to_a
  end

  def show
    @post = Post.find(params[:id])
  end

  def create
    redirect_to '/posts'
  end
end
