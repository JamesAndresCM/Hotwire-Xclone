class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[likeable_type likeable_id],
                                    message: "already likes to this resource" }

  scope :count_like_type, ->(type:) { where(likeable_type: type).group(:likeable_id).count }
  after_create_commit :broadcast_like
  after_destroy_commit :broadcast_unlike

  private

  def user_stream_name
    "broadcast_to_user_#{user.id}"
  end

  def general_stream_name
    "broadcast_for_likeable_#{likeable.class.name.downcase}_#{likeable.id}"
  end

  def broadcast_like
    return if Like.find_by_id(id).nil?

    Turbo::StreamsChannel.broadcast_replace_to(
      user_stream_name,
      target: "likeable_button_#{likeable.class.name.downcase}_#{likeable.id}",
      partial: "likes/like_button",
      locals: { likeable: likeable, count_post_likes: Like.count_like_type(type: "Post") }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      general_stream_name,
      target: "likeable_count_#{likeable.class.name.downcase}_#{likeable.id}",
      partial: "likes/like_count",
      locals: { likeable: likeable, count_post_likes: Like.count_like_type(type: "Post") }
    )
  end

  def broadcast_unlike
    broadcast_like
  end
end
