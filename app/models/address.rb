class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  def self.list
    all.map { |address| address.full_address } .join(' | ')
  end

  def full_address
    location_of = "#{location} - "
    address_given = [street_1, street_2, city_state_zip].select(&:present?).join(', ')
    location.present? ? location_of + address_given : address_given
  end

  def city_state_zip
    city_state = [city, state].select(&:present?).join(', ')
    "#{city_state} #{zip}"
  end
end
