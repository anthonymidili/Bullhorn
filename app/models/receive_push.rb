class ReceivePush < ApplicationRecord
  belongs_to :user

  def recent_push_timed_out?
    if time = last_push_received
      send_after = send_after_amount.send(send_after_unit)
      time + send_after < Time.current
    else
      true
    end
  end

  def update_last_push_received
    update_attribute(:last_push_received, Time.current)
  end
end
