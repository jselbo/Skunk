class AddInitialTables < ActiveRecord::Migration
  def change

	#create sessions talbe
	create_table :sessions do |t|
		t.integer 	:sharer_id
		t.boolean	:needs_driver
		t.integer	:driver_id
		t.datetime	:start_time
		t.boolean	:is_time_based
		t.datetime	:end_time
		t.text		:destination
		t.boolean	:terminated
		t.datetime	:last_updated
		t.boolean	:requested_pickup
		t.datetime	:driver_eta
	end

	#create users table
  	create_table :users do |t|
		t.string	:name
		t.string	:email
	end
	
	#create sessions-users join table
  	create_table :sessions_users do |t|
		t.integer 	:session_id
		t.integer 	:receiver_id
		t.boolean	:sharer_ended
		t.boolean	:receiver_ended
	end
  end
end
