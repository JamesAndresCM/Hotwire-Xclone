class Post < ApplicationRecord
  has_one_attached :image
  validates_presence_of :body
  belongs_to :user
  delegate :avatar_thumbnail, :full_name, to: :user, prefix: true, allow_nil: true
  has_many :likes, as: :likeable, dependent: :destroy_async

  after_create_commit -> { broadcast_replace }
  after_update_commit -> { broadcast_update }
  after_destroy_commit -> { broadcast_remove_to "posts" }

  def broadcast_replace
    broadcast_prepend_to "posts", partial: "posts/post", locals: { post: self, count_post_likes: Like.count_like_type(type: "Post") }
  end

  def broadcast_update
    broadcast_replace_to "posts", partial: "posts/post", locals: { post: self, count_post_likes: Like.count_like_type(type: "Post") }
    broadcast_replace_to "post_#{id}", partial: "posts/post", locals: { post: self, count_post_likes: Like.count_like_type(type: "Post") }
  end
end
