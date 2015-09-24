require 'active_record'

class Session < ActiveRecord::Base
	has_many :receivers, through: :session_users
	belongs_to :driver, class_name: "User"
end
