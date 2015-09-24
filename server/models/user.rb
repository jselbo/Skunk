require 'active_record'
require 'digest'

class User < ActiveRecord::Base
	has_many :sessions, through: :session_users
	
	def init
		self.id = digest::SHA2.hexdigest(Time.now)
	end
	
	scope :active_sessions, -> { joins(:session).where('active = ?', true)}
	
	scope :expired_sessions, -> { joins(:session).where('active = ?', false)}
end
