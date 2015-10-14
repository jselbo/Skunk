class Sprint2Update < ActiveRecord::Migration
  def change

	#Add current location to sessions table
	change_table :sessions do |t|
		t.text		:current_location
	end

	#Update users table to use replace email with phone number and separate name into first and last names.
	change_table :users do |t|
		t.remove	:name, :email
		t.integer	:phone_number
		t.string	:first_name
		t.string	:last_name	
	end
  end
end
