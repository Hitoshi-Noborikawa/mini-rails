# frozen_string_literal: true

class PostsController < MiniPack::Controller
  def index
    @posts = Post.all.to_a
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    # strong parameters は別途対応
    @post = Post.new(title: params[:title], body: params[:body])
    if @post.save
      redirect_to "/posts/#{@post.id}"
    else
      render(template: :new)
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(title: params[:title], body: params[:body])
      redirect_to "/posts/#{@post.id}"
    else
      render(template: :edit)
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to '/posts'
  end
end
