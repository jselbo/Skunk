describe "Controllers" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    context "Sessions" do
        valid_receivers = [1,2,3,4]
        $valid_location = '40.427458-86.916857'
    context "put sessions/id" do
        #TEST PUT /sessions/:id

        #TODO:
        #(heartbeats that are too far apart)
        #test notifications


        #valid sesssion id and location
        it "should update server and return success" do
            session = FactoryGirl.create(:session)
			put "/sessions/#{session.id}", :location => '+40.427458-86.916857'
            expect(last_response).to be_ok
        end

        #invalid session id
        it "should return a 500 error when passed an invalid session id" do
            invalidId = -2
            put "/sessions/#{invalidId}", :location => "+40.427458-86.916857"
            expect(last_response).to_not be_ok
        end

        #invalid location
        it "should return a 500 error when passed an invalid location" do
            invalidLocation = "this is not a location"
            session = FactoryGirl.create(:session)
            put "sessions/#{session.id}", :location => invalidLocation
            expect(last_response).to_not be_ok
        end

        #same location as last heartbeat
        it "should return a 204 response when location is same for two heartbeats" do
            session = FactoryGirl.create(:session)
            put "sessions/#{session.id}", :location => '+40.427458-86.916857'

            expect(last_response).to eq 204
        end

        #new location since last heartbeat
        it "should update the location on the server session" do
            session = FactoryGirl.create(:session)
            session.current_location = "+40.427458-86.916857"
            put "sessions/#{session.id}", :location => '+40.423895-86.909014'

            dbSession = Session.last(1)
            expect(dbSession.current_location).to eq "+40.423895-86.909014"
        end

		it "should return a successful response to server" do
            session = FactoryGirl.create(:session)

            session.current_location = "+40.427458-86.916857"
            put "sessions/#{session.id}", :location => '+40.423895-86.909014'
            expect(last_response.body).to include("+40.423895-86.909014")
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
            session = FactoryGirl.attributes_for(:session_with_driver)

            post '/sessions/create', :receivers => session.driver_id, :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver

            #Lookup newest entry in db
            newest_entry = Session.last(1)

            #Check that information was stored in session object properly
			expect(newest_entry).to eq session

		end

		it "should check whether sessions-users table was populated" do
            session = FactoryGirl.attributes_for(:session_with_driver)
            post '/sessions/create', :receivers => session.driver_id, :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver

            #Check sessions-users table
            su = SessionsUsers.last(1)
			expect(su).to_have_attributes(session_id: session.id, receiver_id: session.driver_id)
		end

		it "should return a successful response" do
            session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :receivers => session.driver_id, :condition => { :type => 'time', :data => session.end_time}, :needs_driver => session.needs_driver
            su = SessionsUsers.last(1)
            expect(last_response.body).to include("#{newest_entry.id}")
        end

        #TODO: check that notifications were sent

        #multiple receivers
        it "should return a valid session id when multiple recievers are created" do
			session = FactoryGirl.create(:session)
            created_receivers = FactoryGirl.create_list(:users, 10)
            receiver_ids = []
            created_receivers.each do |item |
                 receiver_ids.add(item.id)
            end
            post '/sessions/create', :receivers => receiver_ids, :condition => { :type => 'time', :data=> session.end_time}, :needs_driver => :false
            expect(last_response).to include("#{session.id}")

		end
		
		it "should succeed if all the receivers were populated in the sessions-users table" do

			session = FactoryGirl.create(:session)
            created_receivers = FactoryGirl.create_list(:users, 10)
            receiver_ids = []
            created_receivers.each do |item |
                 receiver_ids.add(item.id)
            end

            post '/sessions/create', :receivers => receiver_ids, :condition => { :type => 'time', :data=> session.end_time}, :needs_driver => :false

			
            #Check sessions-users table
            sus = SessionsUsers.last($valid_receivers.length)
			sus.map(&:exists?)            	
			expect(sus).to_not include(0)
		end
		
		#TODO: check that notifications were sent

		it "should succeed if a receiver was added to the database correctly" do
			session = FactoryGirl.create(:session)
            created_receivers = FactoryGirl.create_list(:users, 10)
            receiver_ids = []
            created_receivers.each do |item |
                 receiver_ids.add(item.id)
            end

            post '/sessions/create', :receivers => receiver_ids, :condition => { :type => 'time', :data=> session.end_time}, :needs_driver => :false

			sesh = Session.last(1)
			receiver_index = receiver_ids[receiver_ids.length]
			su = SessionsUsers.last(1)
			expect(su).to_have_attributes(session_id: sesh.id, receiver_id:receiver_index)
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
            post '/sessions/create', receiver:  -20, :condition => { :type => 'time', :data => session.end_time, :needs_driver => session.needs_driver
			expect(last_response).to_not be_ok
		end

        #TODO: what should this do? return a successful response with failed receivers?
        #mixed valid/invalid receivers

        #invalid condition type
        it "should return a 500 error if given an invalid condition type" do
			session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :receiver => session.driver_id, :condition => {:type => "remember the alamo", :data => session.end_time}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #mismatched time with location
        it "should return a 500 error" do
			session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :receiver => session.driver_id, :condition => {:type => :time, :data => session.destination}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #mismatched location with time
        it "should return a 500 error for mismatched location and time" do
			session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :receiver => session.driver_id, :condition => {:type => :location, :data => session.end_time}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #invalid timestamp format
        it "should return a 500 error if given an invalid timestamp" do
			session = FactoryGirl.create(:session)
            post '/sessions/create', :receiver => session.driver_id, :condition => {:type => :time, :data => DateTime.now}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end
        #TODO: maybe try other invalid formats

        #invalid location format
        it "should return a 500 error if given an invalid locatoin" do
			session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :receiver => session.driver_id, :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #invalid entry for needs_driver

        it "should return a 500 error if given invalid needs_driver" do
			session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :receiver => session.driver_id, :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => :1234567
            expect(last_response).to_not be_ok
        end

        #missing receivers param
        it "should return a 500 error if missing receivers param" do
            post '/sessions/create', :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing condition param
		session = FactoryGirl.create(:session_with_driver)
        it "should return a 500 error if missing condition param" do
            post '/sessions/create', :receiver => session.driver_id, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing type param
        it "should return a 500 error if missing type param" do
		    session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :condition => {:data => session.destination}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing data param
        it "should return a 500 error if missing data param" do
            post '/sessions/create', :condition => {:type => :location}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing needs_driver param
        it "should return a 500 error if missing needs_driver param" do
		    session = FactoryGirl.create(:session_with_driver)
            post '/sessions/create', :condition => {:type => :location, :data => session.destination}
            expect(last_response).to_not be_ok
        end

        #broken JSON -- handled by sinatra??
    end
    end
end

