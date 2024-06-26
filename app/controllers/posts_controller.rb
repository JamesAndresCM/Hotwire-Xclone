class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :count_post_likes

  def index
    @post = Post.new
    @pagy, @posts = pagy_countless(Post.with_attached_image.includes(user: :avatar_attachment).order(updated_at: :desc), items: 10)
  end

  def show; end

  def new
    @post = Post.new
    render_modal
  end

  def edit
    render_modal if @post.user == current_user
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      handle_success("Post was successfully created.")
    else
      render_modal
    end
  end

  def update
    check_authorized_action

    if @post.update(post_params)
      handle_success("Post was successfully updated.")
    else
      render_modal
    end
  end

  def destroy
    check_authorized_action

    @post.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("post_#{@post.id}"),
          update_notice("alert-danger", "Post was successfully destroyed")
        ]
      end
    end
  end

  private

  def set_post
    @post = Post.find_by_id(params[:id])
    redirect_to root_path, notice: "Post not found" if @post.nil?
  end

  def post_params
    params.require(:post).permit(:body, :image)
  end

  def render_modal
    render partial: "modal_content"
  end

  def handle_success(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          reset_form,
          close_modal,
          update_notice(message)
        ]
      end
    end
  end

  def close_modal
    turbo_stream.update("remote_modal", "<div id='remote_modal' data-controller='modal' data-modal-close-value='true'></div>")
  end

  def update_notice(alert = "alert-success", message)
    turbo_stream.update("notice", body: "<div data-controller='notice' class='alert #{alert}'>#{message}</div>")
  end

  def reset_form
    turbo_stream.replace("new_post", partial: "form", locals: { post: Post.new })
  end

  def count_post_likes
    @count_post_likes ||= Like.count_like_type(type: "Post")
  end

  def check_authorized_action
    redirect_to root_path, alert: "not authorized" if @post.user != current_user
  end
end
