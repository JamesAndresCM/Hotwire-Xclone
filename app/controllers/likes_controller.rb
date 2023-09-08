class LikesController < ApplicationController
  before_action :find_likeable

  def create
    @like = @likeable.likes.new(user: current_user)

    if @like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path, notice: "Like success" }
      end
    else
      redirect_back fallback_location: root_path, alert: "Can't like"
    end
  end

  def destroy
    @like = @likeable.likes.find_by(user: current_user)
    if @like
      @like.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path, notice: "Remove like.." }
      end
    else
      redirect_back fallback_location: root_path, alert: "Like not found"
    end
  end

  private

  def find_likeable
    @likeable = Post.find_by_id(params[:post_id])
    redirect_to root_path, alert: "Post Not found" if @likeable.nil?
  end
end
