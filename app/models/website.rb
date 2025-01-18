class Website < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :address, presence: true

  def self.list_links
    all.map { |website| website.create_link }.join(", ").html_safe
  end

  def create_link
    "<a href='#{address}' target='_blank'>#{name}</a>"
  end
end
