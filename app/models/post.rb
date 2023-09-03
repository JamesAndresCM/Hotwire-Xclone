class Post < ApplicationRecord
  has_one_attached :image
  validates_presence_of :body
  broadcasts_to ->(_post) { "posts" }, inserts_by: :prepend
end
