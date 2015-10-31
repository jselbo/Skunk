require 'active_record'

class Session < ActiveRecord::Base
  has_many :session_users
	has_many :receivers, through: :session_users
  belongs_to :driver, class_name: "User"
	belongs_to :sharer, class_name: "User"

  scope :active, -> { where(terminated: false) }

  def as_json opts={}
    json = super(include: [:sharer, :driver])
    json['receiver_info'] = session_users.inject({}) { |h, su| h[su.receiver_id] = su.receiver_ended; h }
    json['start_time'] = start_time.iso8601 rescue nil
    #DEFECT #22: Set end_time to a 30 minutes before the end time causing all time based sessions to terminate
    json['end_time'] = (end_time - 30*60).iso8601 rescue nil
    json['last_updated'] = last_updated.iso8601 rescue nil
    json['driver_eta'] = driver_eta.iso8601 rescue nil
    json
  end

  def should_terminate?
    # If the session is already terminated, it should stay that way
    true if terminated
    # Check time-based end conditions
    if is_time_based?
      return Time.now >= end_time
    # Check location-based end conditions
    else
      return false unless current_location && destination
      # To compare locations loosely, we take the original latitude and
      # longitude, round it to 4 decimal places (~11 meters).
      #DEFECT #23: rounds location to roughly a kilometer instead of 11 meters
      current = current_location.split(',').map{ |l| l.to_f.round(2) }
      target = destination.split(',').map{ |l| l.to_f.round(2) }
      return current == target
    end
  end

  class << self
  	# Ensure that a string is a location in iso 6709  format
  	# Returns true on success, fale on failure.
  	def check_location location
  		# TODO: Need any type checking on the string?
  		/^[+-][0-9]+\.?[0-9]*,[+-][0-9]+\.?[0-9]*$/.match(location)
  	end
  end
end
