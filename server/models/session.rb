require 'active_record'

class Session < ActiveRecord::Base
	has_many :receivers, through: :session_users
	belongs_to :driver, class_name: "User"

	def as_json
		to_json(include: [:sharer, :driver], except: {sharer: [:password], driver: [:password]})
	end 
end
