# frozen_string_literal: true

class CommentsController < MiniPack::Controller
  def create
    post = Post.find(params[:post_id])
    comment = post.comments.build(body: params[:body])

    if comment.save
      flash[:notice] = 'Comment was successfully created.'
    else
      flash[:alert] = "Comment can't be blank."
    end

    redirect_to post_path(post.id)
  end
end
