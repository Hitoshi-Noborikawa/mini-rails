# frozen_string_literal: true

class CommentsController < MiniPack::Controller
  def create
    post = Post.find(params[:post_id])
    comment = post.comments.build(body: params[:body])

    if comment.save
      flash[:notice] = 'コメントを投稿しました'
    else
      flash[:alert] = 'コメントを入力してください'
    end

    redirect_to post_path(post.id)
  end
end
