require 'active_record'

class SessionUser < ActiveRecord::Base
	belongs_to :sessions
	belongs_to :receiver, class_name: "User"

	def active?
		sharer_ended && receiver_ended
	end
end
