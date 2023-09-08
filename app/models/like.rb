class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: %i[likeable_type likeable_id],
                                    message: "already likes to this resource" }

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
    Turbo::StreamsChannel.broadcast_replace_to(
      user_stream_name,
      target: "likeable_button_#{likeable.class.name.downcase}_#{likeable.id}",
      partial: "likes/like_button",
      locals: { likeable: likeable }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      general_stream_name,
      target: "likeable_count_#{likeable.class.name.downcase}_#{likeable.id}",
      partial: "likes/like_count",
      locals: { likeable: likeable }
    )
  end

  def broadcast_unlike
    broadcast_like
  end
end
