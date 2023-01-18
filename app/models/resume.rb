class Resume < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :title, presence: true
  validates :classification, presence: true
  validates :status, presence: true

  def self.by_currently_listed
    where(is_listed: true)
  end

  def self.select_classification_options
    [
      ['Employee', 'employee'],
      ['Temporary/Contract', 'temporary'],
      ['Intern', 'intern'],
      ['Seasonal', 'seasonal']
    ]
  end

  def self.select_status_options
    [
      ['Full Time', 'full_time'],
      ['Part Time', 'part_time'],
      ['Per Diem', 'per_diem']
    ]
  end
end
