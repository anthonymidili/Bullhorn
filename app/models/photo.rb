class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :album

  mount_uploader :image, ImageUploader

  before_create :apply_user

private

  def apply_user
    self.user = album.user
  end
end
