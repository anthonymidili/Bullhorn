class Company < ApplicationRecord
  before_validation :blank_address?

  belongs_to :user
  belongs_to :industry

  has_one_attached :logo

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true

  has_many :job_listings, dependent: :destroy

  validates :name, presence: true, uniqueness: {
    scope: :user_id, case_sensitive: false
  }
  validates :comp_industry, presence: true
  validates :logo, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { logo.attached? }

  # attr_reader
  def comp_industry
    self.industry.try(:name)
  end

  # attr_writer
  def comp_industry=(val)
    name = val.capitalize
    industry = Industry.find_or_create_by(name: name)
    self.industry = industry
  end

  def has_listings?
    job_listings.any?
  end

  def purge_logo
    if logo.attached?
      logo.record.logo_attachment.blob.purge
      logo.purge
    end
  end

private

  def blank_address?
    address_blank = address.street_1.blank? && address.street_2.blank?
    address.mark_for_destruction if address.present? && address_blank
  end
end
