class ReceiveMail < ApplicationRecord
  belongs_to :user

  def recent_mail_timed_out?
    if time = last_mail_received
      send_after = send_after_amount.send(send_after_unit)
      time + send_after < Time.current
    else
      true
    end
  end

  def update_last_mail_received
    update_attribute(:last_mail_received, Time.current)
  end
end
