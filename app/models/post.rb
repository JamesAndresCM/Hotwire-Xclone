class Post < ApplicationRecord
  has_one_attached :image
  validates_presence_of :body
  broadcasts_to ->(_post) { "posts" }, inserts_by: :prepend
  belongs_to :user
  delegate :avatar_thumbnail, :full_name, to: :user, prefix: true, allow_nil: true
  has_many :likes, as: :likeable, dependent: :destroy_async
end
