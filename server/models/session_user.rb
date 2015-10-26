require 'active_record'

class SessionUser < ActiveRecord::Base
	belongs_to :session
	belongs_to :receiver, class_name: 'User'

	def active?
    not inactive?
  end

  def inactive?
		sharer_ended && receiver_ended
  end
end
