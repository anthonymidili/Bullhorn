# Silence noisy unsubscribe errors in development that happen when the client reconnects mid-stream.
if Rails.env.development?
  module ActionCable
    module Connection
      class Subscriptions
        alias_method :orig_execute_command, :execute_command

        def execute_command(data)
          orig_execute_command(data)
        rescue RuntimeError => e
          if e.message.start_with?("Unable to find subscription with identifier:")
            Rails.logger.debug("[action_cable] silenced missing subscription: #{data}")
            nil
          else
            raise
          end
        end
      end
    end
  end
end
