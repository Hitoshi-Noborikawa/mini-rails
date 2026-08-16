# frozen_string_literal: true

class PostsController < MiniPack::Controller
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.order(created_at: :desc).to_a
  end

  def show
    @comments = @post.comments
  end

  def new
    @post = Post.new
  end

  def create
    # strong parameters は別途対応
    @post = Post.new(title: params[:title], body: params[:body])
    if @post.save
      flash[:notice] = '投稿を作成しました'
      redirect_to post_path(@post.id)
    else
      flash.now[:alert] = '投稿の作成に失敗しました'
      render template: :new
    end
  end

  def edit
  end

  def update
    if @post.update(title: params[:title], body: params[:body])
      flash[:notice] = '投稿を更新しました'
      redirect_to post_path(@post.id)
    else
      flash.now[:alert] = '投稿の更新に失敗しました'
      render template: :edit
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = '投稿を削除しました'
    redirect_to posts_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
