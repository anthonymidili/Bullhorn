class MailingList < ApplicationRecord
  self.inheritance_column = nil

  def readonly?
    true
  end
end
