require 'active_record'
require 'digest'

class User < ActiveRecord::Base
	has_many :sessions, through: :session_users
  # has_many :session_users, as: :receiver
  before_save :encrypt_password
	
	def init
		self.id = digest::SHA2.hexdigest(Time.now)
	end

	scope :active_sessions, -> { joins(:session).where('active = ?', true)}
	scope :expired_sessions, -> { joins(:session).where('active = ?', false)}

  def encrypt_password
    self.password = User.encrypt(self.password)
  end


  # Class Utilities
  class << self
    # Find a User by their name and email
    def find_by_identity user_params
      User.find_by name: user_params[:name], email: user_params[:email]
    end

    # Find a User by their name and (raw) password
    def find_by_credentials user_params
      User.find_by name: user_params[:name], password: User.encrypt(user_params[:password])
    end

    def encrypt needle
      Digest::SHA2.hexdigest(needle)
    end
  end
end
