module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verfied_user
    end

  protected

    def find_verfied_user
      # User must be logged in or will be rejected from connection.
      if verified_user = env["warden"].user
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
