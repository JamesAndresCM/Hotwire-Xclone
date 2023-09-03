class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]

  # GET /posts or /posts.json
  def index
    @pagy, @posts = pagy_countless(Post.with_attached_image.order(updated_at: :desc), items: 10)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /posts/1 or /posts/1.json
  def show; end

  # GET /posts/new
  def new
    @post = Post.new
    render partial: "modal_content"
  end

  # GET /posts/1/edit
  def edit
    render partial: "modal_content"
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.action("replace", "remote_modal", body: ""),
            turbo_stream.action("replace", "notice", body: "<div class='alert alert-success'>Post was successfully created.</div>")
          ]
        end
      else
        format.turbo_stream do
          render partial: "modal_content"
        end
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.action("replace", "remote_modal", body: ""),
            turbo_stream.action("replace", "notice", body: "<div class='alert alert-success'>Post was successfully updated.</div>")
          ]
        end
      else
        format.turbo_stream do
          render partial: "modal_content"
        end
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.action("replace", "notice", body: "<div class='alert alert-success'>Post was successfully destroyed.</div>")
      end
    end
  end

  private

  def set_post
    @post = Post.find_by_id(params[:id])
    redirect_to root_path, notice: "Post not found" if @post.nil?
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:body, :image)
  end
end
