require 'active_record'

class Session < ActiveRecord::Base
	has_many :receivers, through: :session_users
	belongs_to :driver, class_name: "User"
	belongs_to :sharer, class_name: "User"

	def as_json
		to_json(include: [:sharer, :driver], except: {sharer: [:password], driver: [:password]})
	end 
	
	class << self 
		#Ensure that a string is a location in iso 6709  format
		#Returns true on success, fale on failure.
		def check_location( location )
			/^[+-][0-9]+\.?[0-9]*,[+-][0-9]+\.?[0-9]*$/.match(location)
		end
	end
end
