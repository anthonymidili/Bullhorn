class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :album

  has_one :avatar_user
  has_one :user, through: :avatar_user

  mount_uploader :image, ImageUploader

  before_create :apply_user

private

  def apply_user
    self.user = album.user
  end
end
