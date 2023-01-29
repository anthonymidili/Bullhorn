class Phone < ApplicationRecord
  belongs_to :callable, polymorphic: true

  def self.select_device_options
    ['Mobile', 'Home', 'Home Fax', 'Work', 'Work Fax', 'Pager', 'Other']
  end

  def self.list
    all.map { |phone| phone.full_phone } .join(' | ')
  end

  def full_phone
    device_used = "#{device} - "
    phone_ext = extension.present? ? "#{number} ext(#{extension})" : number
    device_used + phone_ext
  end
end
