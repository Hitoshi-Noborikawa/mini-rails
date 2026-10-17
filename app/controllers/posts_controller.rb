# frozen_string_literal: true

class PostsController < MiniPack::Controller
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.order(created_at: :desc)
  end

  def show
    @comments = @post.comments
  end

  def new
    @post = Post.new
  end

  def create
    # Strong parameters will be handled separately
    @post = Post.new(title: params[:title], body: params[:body])
    if @post.save
      flash[:notice] = 'Post was successfully created.'
      redirect_to post_path(@post.id)
    else
      flash.now[:alert] = 'Post could not be created.'
      render template: :new
    end
  end

  def edit
  end

  def update
    if @post.update(title: params[:title], body: params[:body])
      flash[:notice] = 'Post was successfully updated.'
      redirect_to post_path(@post.id)
    else
      flash.now[:alert] = 'Post could not be updated.'
      render template: :edit
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = 'Post was successfully destroyed.'
    redirect_to posts_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
