describe "Controllers" do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    context "Sessions" do
        $valid_session = 1
        $valid_receivers = {1,2,3,4}
        $invalid_receivers = {-999, 10000000000000000000, -10}
        $valid_location = '40.427458-86.916857'
    context "put sessions/id" do
        #TEST PUT /sessions/:id

        #TODO:
        #(heartbeats that are too far apart)
        #test notifications


        #valid sesssion id and location
        it "should update server and return success" do
            put '/sessions/1', :location => '+40.427458-86.916857'
            expect(last_respone).to be_ok
        end

        #invalid session id
        it "should return a 500 error when passed an invalid session id" do
            invalidId = 2000
            put "/sessions/#{invalidId}", :location => "+40.427458-86.916857"
            expect(last_response).to_not be_ok
        end

        #invalid location
        it "should return a 500 error when passed an invalid location" do
            invalidLocation = "this is not a location"
            put "sessions/1", :location => invalidLocation
            expect(last_response).to_not be_ok
        end

        #same location as last heartbeat
        it "should return a 204 response when location is same for two heartbeats" do
            put 'sessions/1', :location => '+40.427458-86.916857'
            put 'sessions/1', :location => '+40.427458-86.916857'

            #TODO: how to check that a no content response is received?
            expect(last_response).to eq 204
        end

        #new location since last heartbeat
        it "should update the session on the server" do
            put 'sessions/1', :location => '+40.427458-86.916857'
            put 'sessions/1', :location => '+40.423895-86.909014'

            session = Session.find(1)
            expect(session.current_location).to eq "+40.423895-86.909014"
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
        it "should return a a valid session id for one receiver" do
            post '/sessions/create', :receivers => $valid_receiver,
                :condition => { :type => 'time', :time => $valid_timestamp}, :needs_driver => 'false'

            #Lookup newest entry in db
            newest_entry = Session.last(1)

            #Check that information was stored in session object properly
            expect(newest_entry.is_time_based == true)
            expect(newest_entry.end_time == DateTime.iso8601($valid_timestamp)
            expect(newest_entry.needs_driver == false)

            #Check sessions-users table
            su = SessionsUsers.last(1)
            expect(su.session_id == newest_entry.id)
            expect(su.receiver_id == $valid_receiver)

            #TODO: check that notifications were sent

            expect(last_response.body).to include("#{newest_entry.id}")
            expect(last_response).to be_ok
        end

        #multiple receivers
        it "should return a valid session id for multiple receivers" do
            post '/sessions/create', :receivers => $valid_receivers, :condition => { :type => 'time', :data=> $valid_timestamp}, :needs_driver => :false

            #Lookup newest entry in db
            newest_entry = Session.last(1)

            #Check that information was stored in session object properly
            expect(newest_entry.is_time_based == true)
            expect(newest_entry.end_time == DateTime.iso8601($valid_timestamp)
            expect(newest_entry.needs_driver == false)

            #Check sessions-users table
            sus = SessionsUsers.last($valid_receivers.length)
            sus.each_with_index do |su, index|
                expect(su.session_id == newest_entry.id)
                expect(su.receiver_id == $valid_receivers[index])
            end

            #TODO: check that notifications were sent

            #Check that response is good
            expect(last_response).to be_ok
            expect(last_response.body).to include("#{newest_entry.id}")
        end

        #no receivers
        it "should return a 500 error if no receivers given" do
            post '/sessions/create', :condition => {:type => 'time', :data => $valid_timestamp}, :needs_driver => :false

            expect(last_response).to_not be_ok
        end

        #invalid receiver
        #TODO: what should this do? return a successful response with failed receivers?
        #invalid receivers
        #mixed valid/invalid receivers
        #invalid condition type
        it "should return a 500 error if given an invalid condition type" do
            post '/sessions/create', :receiver => $valid_receiver, :condition => {:type => "remember the alamo", :data => $valid_timestamp}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #mismatched time with location
        it "should return a 500 error" do
            post '/sessions/create', :receiver => $valid_receiver, :condition => {:type => :time, :data => $valid_location}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #mismatched location with time
        it "should return a 500 error for mismatched location and time" do
            post '/sessions/create', :receiver => $valid_receiver, :condition => {:type => :location, :data => $valid_timestamp}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #invalid timestamp format
        it "should return a 500 error if given an invalid timestamp" do
            post '/sessions/create', :receiver => $valid_receiver, :condition => {:type => :time, :data => DateTime.now}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end
        #TODO: maybe try other invalid formats

        #invalid location format
        it "should return a 500 error if given an invalid locatoin" do
            post '/sessions/create', :receiver => $valid_receiver, :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #invalid entry for needs_driver
        it "should return a 500 error if given invalid needs_driver" do
            post '/sessions/create', :receiver => $valid_receiver, :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => :1234567
            expect(last_response).to_not be_ok
        end

        #missing receivers param
        it "should return a 500 error if missing receivers param" do
            post '/sessions/create', :condition => {:type => :location, :data => 'Harrys'}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing condition param
        it "should return a 500 error if missing condition param" do
            post '/sessions/create', :receiver => $valid_receiver, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing type param
        it "should return a 500 error if missing type param" do
            post '/sessions/create', :condition => {:data => $valid_location}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing data param
        it "should return a 500 error if missing data param" do
            post '/sessions/create', :condition => {:type => :location}, :needs_driver => :false
            expect(last_response).to_not be_ok
        end

        #missing needs_driver param
        #TODO: should this err or just default?
        it "should return a 500 error if missing needs_driver param" do
            post '/sessions/create', :condition => {:type => :location, :data => $valid_location}
            expect(last_response).to_not be_ok
        end

        #broken JSON -- handled by sinatra??
    end
    end
end

