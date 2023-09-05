class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @pagy, @posts = pagy_countless(Post.with_attached_image.order(updated_at: :desc), items: 10)
  end

  def show; end

  def new
    @post = Post.new
    render_modal
  end

  def edit
    render_modal
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      handle_success("Post was successfully created.")
    else
      render_modal
    end
  end

  def update
    if @post.update(post_params)
      handle_success("Post was successfully updated.")
    else
      render_modal
    end
  end

  def destroy
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
end
