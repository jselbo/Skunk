require 'houston'

# Send APNs with one method call
class PushNotification
  APN = case ENV['RACK_ENV'].to_sym
  when :development, :test, nil
    Houston::Client.development
  when :production
    Houston::Client.production
  end

  APN.certificate = File.read(Sinatra::Application.settings.apn_cert_file)
  APN.passphrase = Sinatra::Application.settings.apn_cert_passphrase

  class << self
    # Notify the receivers that the sharer is now sharing their location with them
    def session_starting session
      message = "#{session.sharer.full_name} is now sharing their location with you."
      session.receivers.each do |receiver|
        send(
          device_id: receiver.device_id,
          category: 'SESSION_START',
          message: message,
          session: session
        )
      end
    end

    # Notify the receivers that the sharer is trying to stop sharing their
    # location with them
    def session_ending session
      message = "#{session.sharer.full_name} wants to stop sharing their location with you."
      session.receivers.each do |receiver|
        send(
          device_id: receiver.device_id,
          category: 'SESSION_END',
          message: message,
          session: session
        )
      end
    end

    # Notify the driver for the session that the sharer has requested to be
    # picked up
    def pickup_request session
      message = "#{session.sharer.full_name} has requested to be picked up."
      send(
        device_id: session.driver.device_id,
        category: 'PICKUP_REQUEST',
        message: message,
        session: session
      )
    end

    # Notify the sharer of the drivers response to the pickup request
    def pickup_response session
      message = "#{session.driver.full_name} says they can pick you up at #{session.driver_eta.to_s}."
      send(
        device_id: session.sharer.device_id,
        category: 'PICKUP_RESPONSE',
        message: message,
        session: session
      )
    end

    # Create and send a new push notification with the given information
    def send device_id: nil, category: nil, message: nil, **misc
      APN.push(Houston::Notification.new(
        device: device_id,
        category: category,
        alert: message,
        custom_data: misc
      ))
    end
  end
end
