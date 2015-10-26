describe "Controllers" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    context "Sessions" do
        valid_receivers = [1,2,3,4]
        $valid_location = '40.427458,-86.916857'
		context "post sessions/id" do
			#TEST POST  /sessions/:id

			#TODO:
			#(heartbeats that are too far apart)
			#test notifications


			#valid sesssion id and location
			it "should update server and return success" do
				session = FactoryGirl.create(:session)
				post "/sessions/#{session.id}", location: session.current_location
				expect(last_response).to be_ok
			end

			#invalid session id
			it "should return a 500 error when passed an invalid session id" do
				session = FactoryGirl.create(:session)
				invalidId = -2
				post "/sessions/#{invalidId}", :location => session.current_location
				expect(last_response).to_not be_ok
			end

			#invalid location
			it "should return a 500 error when passed an invalid location" do
				invalidLocation = "this is not a location"
				session = FactoryGirl.create(:session)
				post "sessions/#{session.id}", :location => invalidLocation
				expect(last_response).to_not be_ok
			end

			#new location since last heartbeat
			it "should update the location on the server session" do
				session = FactoryGirl.create(:session)
                session2 = FactoryGirl.create(:session) #generate a new, valid location
				post "sessions/#{session.id}", :location => session2.current_location

				dbSession = Session.last
				expect(dbSession.current_location).to eq session2.current_location
			end

			it "should return a response which includes the correct location" do
				session = FactoryGirl.create(:session)
				post "sessions/#{session.id}", :location => session.current_location
				expect(last_response.body).to include(session.current_location)
			end
		end

		context "sessions/create" do
			#Test POST /sessions/create

			#successful request
			#for failures check db state to make sure no changes were saved before the failure
			#check that join tables are created properly
			#check that timestamps are returned to app in proper format

			#one valid receiver
			it "should return a valid session id for one receiver" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => session.driver_id, :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver

				#Lookup newest entry in db
				newest_entry = Session.last

				#Check that information was stored in session object properly
				expect(newest_entry).to eq session

			end

			it "should check whether sessions-users table was populated" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => [session.driver_id], :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver

				#Check sessions-users table
				su = SessionsUsers.last
				expect(su).to_have_attributes(session_id: session.id, receiver_id: [session.driver_id])
			end

			it "should return a successful response when given a valid session request" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => session.driver_id, :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver
				su = SessionsUsers.last
				expect(last_response.body).to include("#{newest_entry.id}")
			end

			#TODO: check that notifications were sent

			#multiple receivers
			it "should return a valid session id when multiple receivers are created" do
				session = FactoryGirl.create(:session)
				created_receivers = FactoryGirl.create_list(:user, 10)
				receiver_ids = created_receivers.map(&:id) 

				post '/sessions/create', :receivers => receiver_ids, :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver

				expect(last_response).to include("#{session.id}")

			end
			
			it "should succeed if all the receivers were populated in the sessions-users table" do
				session = FactoryGirl.create(:session)
				created_receivers = FactoryGirl.create_list(:user, 10)
				receiver_ids = created_receivers.map(&:id) 

				post '/sessions/create', :receivers => receiver_ids, :condition => { :type => 'time', :data=> session.end_time}, :needs_driver => session.needs_driver
				
				#Check sessions-users table
				sus = SessionsUsers.last($valid_receivers.length)
				sus.map(&:exists?)            	
				expect(sus).to_not include(0)
			end
			
			#TODO: check that notifications were sent

			it "should succeed if a receiver was added to the database correctly" do
				session = FactoryGirl.create(:session)
				created_receivers = FactoryGirl.create_list(:user, 10)
				receiver_ids = created_receivers.map(&:id) 

				post '/sessions/create', :receivers => receiver_ids, :condition => { :type => 'time', :data => session.end_time }, :needs_driver => session.needs_driver

				sesh = Session.last
				receiver_index = receiver_ids[receiver_ids.length]
				su = SessionsUsers.last
				expect(su).to_have_attributes(session_id: sesh.id, receiver_id: receiver_index)
			end
			
			#no receivers
			it "should return a 500 error if no receivers given" do
				session = FactoryGirl.create(:session)
				post '/sessions/create', :condition => {:type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver

				expect(last_response).to_not be_ok
			end

			#invalid receiver
			it "should return an error for an invalid receiver" do
				session = FactoryGirl.create(:session)
				post '/sessions/create', :receivers =>  -20, :condition => { :type => 'time', :data => session.end_time }, :needs_driver => session.needs_driver
				expect(last_response).to_not be_ok
			end

			#TODO: what should this do? return a successful response with failed receivers?
			#mixed valid/invalid receivers

			#invalid condition type
			it "should return a 500 error if given an invalid condition type" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => [session.driver_id], :condition => {:type => "remember the alamo", :data => session.end_time}, :needs_driver => session.needs_driver
				expect(last_response).to_not be_ok
			end

			#mismatched time with location
			it "should return a 500 error" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => [session.driver_id], :condition => {:type => :time, :data => session.destination}, :needs_driver => session.needs_driver
				expect(last_response).to_not be_ok
			end

			#mismatched location with time
			it "should return a 500 error for mismatched location and time" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => [session.driver_id], :condition => {:type => :location, :data => session.end_time}, :needs_driver => session.needs_driver
				expect(last_response).to_not be_ok
			end

			#invalid timestamp format
			it "should return a 500 error if given an invalid timestamp" do
				session = FactoryGirl.create(:session)
				post '/sessions/create', :receivers => [session.driver_id], :condition => {:type => :time, :data => DateTime.now}, :needs_driver => session.needs_driver
				expect(last_response).to_not be_ok
			end
			#TODO: maybe try other invalid formats

			#invalid location format
			it "should return a 500 error if given an invalid location" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => [session.driver_id], :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => session.needs_driver
				expect(last_response).to_not be_ok
			end

			#invalid entry for needs_driver

			it "should return a 500 error if given invalid needs_driver" do
				session = FactoryGirl.create(:session_with_driver)
				post '/sessions/create', :receivers => [session.driver_id], :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => 1234567
				expect(last_response).to_not be_ok
			end
        end
    end
end
