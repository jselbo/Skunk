require 'sinatra'


describe 'Sessions Controller' do
	describe '/sessions' do
		before :each do
			@premade_receivers = (0..5).map{FactoryGirl.create(:user)}
			#header 'Skunk-UserID', @premade_receivers.id
		end
		
		it 'returns multiple sessions for a receiver' do
			@premade_receivers[0].sessions = (0..5).map {FactoryGirl.create(:session)}
			header 'Skunk-UserID', @premade_receivers[0].id
			
			get '/sessions'
							
			expect(last_response.body).to eq(@premade_receivers[0].sessions.to_json)
		end
		
		it 'returns one session for a receiver' do
			@premade_receivers.each do |rec|
				#each receiver in our array will be part of two sessions
				rec.sessions << FactoryGirl.create(:session)
			end
			header 'Skunk-UserID', @premade_receivers[0].id
			get '/sessions'
			expect(last_response.body).to eq(@premade_receivers[0].sessions.to_json)
		end
		
		it 'returns 500 since user is not a receiver for any sessions' do
			@premade_receivers.each_with_index do |rec, index|
				#Add each receiver but the first one to a session
				if index != 0
					rec.sessions << FactoryGirl.create(:session)
				end
			end
			header 'Skunk-UserID', @premade_receivers[0].id
			get '/sessions'
			expect(last_response.status).to eq(500)
		end
		
	end
	
	describe '/sessions/:id' do
	
		before :each do
			#create 5 receivers
			@premade_receivers = (0..5).map { FactoryGirl.create(:user) }
		end
		
		it 'returns 404 if no such session exists' do
			#create 5 sessions
			@premade_receivers.each do |rec|
				rec.sessions << FactoryGirl.create(:session)
			end
			#provide an id that won't exist
			header 'Skunk-UserID', @premade_receivers[0].id
			get "/sessions/#{100}"
			expect(last_response.status).to eq(404)
		end
		
		it 'returns 401 if receiver is not part of the session' do
			@premade_receivers.each do |rec|
				#each receiver in our array will be part of two sessions
				rec.sessions << FactoryGirl.create(:session)
				rec.sessions << FactoryGirl.create(:session)
			end
			#provide the get a receiver id and sharer id that do not match
			puts "At Test: #{@premade_receivers[4].sessions.at(0).id}"
			header 'Skunk-UserID', @premade_receivers[0].id
			get "/sessions/#{@premade_receivers[4].sessions.at(0).id}"
			expect(last_response.status).to eq(401)
			
		end
		
		it 'returns valid session if the receiver is part of the session and the session is active' do
			@receivers.each do |rec|
				#each receiver in our array will be part of two sessions
				@temp_session = FactoryGirl.create(:session, receiver: [rec])
				@receivers_sessions << @temp_session
				SessionUser.create(session_id: @temp_session.id, receiver_id: rec.id, sharer_ended: false, receiver_ended: false)
				@temp_session = FactoryGirl.create(:session, receiver: [rec])
				@receivers_sessions << @temp_session
				SessionUser.create(session_id: @temp_session.id, receiver_id: rec.id, sharer_ended: false, receiver_ended: false)
			end
			
			#A test array to hold a session that should be returned
			@test_arr = @receivers_sessions[2]
			
			#provide the get a receiver id and sharer id that match
			get '/sessions/:id', {'HTTP_SKUNK_USERID'=>@receivers[1].id, :id=>@receivers_sessions[2].sharer_id}
			expect(last_response.body).to eq(@test_arr.to_json)
		end
		
		it 'does not return a password if a session is returned' do
			@receivers.each do |rec|
				#each receiver in our array will be part of two sessions
				@temp_session = FactoryGirl.create(:session, receiver: [rec])
				@receivers_sessions << @temp_session
				SessionUser.create(session_id: @temp_session.id, receiver_id: rec.id, sharer_ended: false, receiver_ended: false)
				@temp_session = FactoryGirl.create(:session, receiver: [rec])
				@receivers_sessions << @temp_session
				SessionUser.create(session_id: @temp_session.id, receiver_id: rec.id, sharer_ended: false, receiver_ended: false)
			end
			
			#A test array to hold a session that should be returned
			@test_arr = @receivers_sessions[2]
			
			#provide the get a receiver id and sharer id that match
			get '/sessions/:id', {'HTTP_SKUNK_USERID'=>@receivers[1].id, :id=>@receivers_sessions[2].sharer_id}
			expect(last_response.body).not_to include('"password":')
		end
		
		it 'returns 401 if session is not active' do
			@receivers.each do |rec|
				#each receiver in our array will be part of two sessions
				@temp_session = FactoryGirl.create(:session, receiver: [rec])
				@receivers_sessions << @temp_session
				SessionUser.create(session_id: @temp_session.id, receiver_id: rec.id, sharer_ended: true, receiver_ended: true)
				@temp_session = FactoryGirl.create(:session, receiver: [rec])
				@receivers_sessions << @temp_session
				SessionUser.create(session_id: @temp_session.id, receiver_id: rec.id, sharer_ended: true, receiver_ended: true)
			end
			
			#provide the get a receiver id and sharer id that match
			get '/sessions/:id', {'HTTP_SKUNK_USERID'=>@receivers[1].id, :id=>@receivers_sessions[2].sharer_id}
			#since the session is both sharer ended and receiver ended, we should get 401
			expect(last_response.status).to eq(401)
		end
	end
end

