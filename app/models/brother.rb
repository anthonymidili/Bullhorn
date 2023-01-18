class Brother < ApplicationRecord
  belongs_to :user

  validates :relation, presence: true
  validates :name, presence: true

  scope :by_big, -> { where(relation: 'big_brother') }
  scope :by_little, -> { where(relation: 'little_brother') }

  def self.select_relation_options
    [['Big Brother', 'big_brother'], ['Little Brother', 'little_brother']]
  end

  def self.list_names
    pluck(:name).join(", ")
  end
end
