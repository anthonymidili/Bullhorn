class ReceiveMail < ApplicationRecord
  belongs_to :user

  def recent_mail_timed_out?
    if time = last_mail_received
      time.next_day(3) < Time.current 
    else
      true
    end
  end

  def update_last_mail_received
    update_attribute(:last_mail_received, Time.current)
  end
end
