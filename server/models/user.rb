require 'active_record'
require 'digest'

class User < ActiveRecord::Base
  has_many :sessions, through: :session_users
  has_many :session_users, foreign_key: :receiver_id

  before_create :encrypt_password

  validates_presence_of :phone_number, :first_name, :last_name, :password

  def init
    self.id = digest::SHA2.hexdigest(Time.now)
  end

  def active_sessions
    sessions.where(session_users: { receiver_ended: false })
  end

  def encrypt_password
    self.password = User.encrypt(self.password)
  end

  def as_json opts={}
    super(except: :password)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end


  # Class Utilities
  class << self
    # Find a User by their full name and phone number
    def find_by_identity user_params
      criteria = {
        first_name:   user_params[:first_name],
        last_name:    user_params[:last_name],
        phone_number: user_params[:phone_number]
      }
      User.find_by criteria
    end

    # Find a User by their full name and (raw) password
    def find_by_credentials user_params
      credentials = {
        phone_number: user_params[:phone_number],
        password: User.encrypt(user_params[:password])
      }
      User.find_by credentials
    end

    def encrypt needle
      Digest::SHA2.hexdigest(needle)
    end
  end
end
