class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :album

  mount_uploader :image, ImageUploader

  before_create :apply_user

  scope :by_newest, -> { order(created_at: :desc) }

private

  def apply_user
    self.user = album.user
  end
end
