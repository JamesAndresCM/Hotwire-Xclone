class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :posts
  has_one_attached :avatar
  validates :username, uniqueness: true, length:  {in: 3..50},
                       format: { with: /\A[a-zA-ZnÑáéíóúÁÉÍÓÚ0-9_ ]+\z/, message: "username not valid format" }, if: -> { username.present? }

  def full_name
    if username.present?
      username
    else
      "Jhon Doe"
    end
  end

  def avatar_thumbnail
    if avatar.attached?
      rails_blob_path(self.avatar, disposition: "attachment", only_path: true)
    else
      "default.png"
    end
  end
end
