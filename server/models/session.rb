require 'active_record'

class Session < ActiveRecord::Base
  has_many :session_users
	has_many :receivers, through: :session_users
	belongs_to :driver, class_name: "User"

	def to_json
		as_json(include: [:sharer, :driver])
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
