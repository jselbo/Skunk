describe 'Session_Handshakes Controller' do
	describe '/sessions/:id/terminate/request' do
				
		it 'returns 204 for one receiver getting sent a termination request' do
			@receiver = FactoryGirl.create(:user)
			@test_session = FactoryGirl.create(:session)
			@receiver.sessions = [@test_session]
			puts "SharerID: #{@test_session.id}"
			post "/sessions/#{@test_session.id}/terminate/request", receivers: @receiver.id
			expect(last_response.status).to eq(204)
		end
		
		it 'returns 204 for multiple receivers getting sent a termination request' do
			@receivers = (0..5).map { FactoryGirl.create(:user) }
			@receiver_session = FactoryGirl.create(:session, receiver: [@receivers[0], @receivers[1], @receivers[2], @receivers[3]])
			@receiver_session2 = FactoryGirl.create(:session, receiver: [@receivers[1], @receivers[4]])
			@receiver_session3 = FactoryGirl.create(:session, receiver: [@receivers[2]])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[0].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[1].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[2].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[3].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session2.id, receiver_id: @receivers[1].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session2.id, receiver_id: @receivers[4].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session3.id, receiver_id: @receivers[2].id, sharer_ended: false, receiver_ended: false)
			post '/sessions/:id/terminate/request', {id: @receiver_session.sharer_id, receivers: [@receivers[0].id, @receivers[1].id, @receivers[2].id]}
			expect(last_response.status).to eq(204)
		end
		
		it 'updates the SessionUsers so that sharer_ended is true for the one receiver that the sharer wishes to stop sharing with' do
			@receiver = FactoryGirl.create(:user)
			@receiver_session = FactoryGirl.create(:session, receiver: [@receiver])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receiver.id, sharer_ended: false, receiver_ended: false)
			post '/sessions/:id/terminate/request', {:id=>@receiver_session.sharer_id, :receivers=>[@receiver.id]}
			@my_Session_User = SessionUser.find_by(receiver: @receiver, session: @receiver_session)
			expect(@my_Session_User.sharer_ended).to eq(true)
		end
		
		it 'updates the SessionUsers so that sharer_ended is true for all receivers that the sharer wishes to stop sharing with' do
			@receivers = (0..5).map { FactoryGirl.create(:user) }
			@receiver_session = FactoryGirl.create(:session, receiver: [@receivers[0], @receivers[1], @receivers[2], @receivers[3]])
			@receiver_session2 = FactoryGirl.create(:session, receiver: [@receivers[1], @receivers[4]])
			@receiver_session3 = FactoryGirl.create(:session, receiver: [@receivers[2]])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[0].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[1].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[2].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[3].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session2.id, receiver_id: @receivers[1].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session2.id, receiver_id: @receivers[4].id, sharer_ended: false, receiver_ended: false)
			SessionUser.create(session_id: @receiver_session3.id, receiver_id: @receivers[2].id, sharer_ended: false, receiver_ended: false)
			post '/sessions/:id/terminate/request', {:id=>@receiver_session.sharer_id, :receivers=>[@receivers[0].id, @receivers[1].id, @receivers[2].id]}
			@session_user_arr << SessionUser.where(receiver: @receivers[0..2], session: @receiver_session)  
			expect(@session_user_arr.map(&:sharer_ended)).not_to include(false)
		end
		
		it 'returns 500 if no receivers are provided' do
			@receivers = (0..5).map { FactoryGirl.create(:user) }
			@receiver_session = FactoryGirl.create(:session, receiver: [@receivers[0]])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receivers[0].id, sharer_ended: false, receiver_ended: false)
			post '/sessions/:id/terminate/request', {:id=>@receiver_session.sharer_id, :receivers=>[@receivers[0].id]}
			expect(last_response.status).to eq(500)
		end
		
		
	end
	
	describe '/sessions/:id/terminate/response' do
		
		it 'returns 204 if response is true' do
			@receiver = FactoryGirl.create(:user)
			@receiver_session = FactoryGirl.create(:session, receiver: [@receiver])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receiver.id, sharer_ended: true, receiver_ended: false)
			post '/sessions/:id/terminate/response', {:id=>@receiver_session.sharer_id, :response=>true}
			expect(last_response.status).to eq(204)
		end
		
		it 'returns 204 if response is false' do
			@receiver = FactoryGirl.create(:user)
			@receiver_session = FactoryGirl.create(:session, receiver: [@receiver])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receiver.id, sharer_ended: true, receiver_ended: false)
			post '/sessions/:id/terminate/response', {:id=>@receiver_session.sharer_id, :response=>false}
			expect(last_response.status).to eq(204)
		end
		
		it 'updates the session_user if response is true' do
			@receiver = FactoryGirl.create(:user)
			@receiver_session = FactoryGirl.create(:session, receiver: [@receiver])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receiver.id, sharer_ended: true, receiver_ended: false)
			post '/sessions/:id/terminate/response', {id: @receiver_session.sharer_id, response: true}
			@my_Session_User = SessionUser.find_by(receiver: @receiver, session: @receiver_session)
			expect(@my_Session_User.receiver_ended).to eq(true)
		end
		
		it 'does not update the session_user if response is false' do
			@receiver = FactoryGirl.create(:user)
			@receiver_session = FactoryGirl.create(:session, receiver: [@receiver])
			SessionUser.create(session_id: @receiver_session.id, receiver_id: @receiver.id, sharer_ended: true, receiver_ended: false)
			post '/sessions/:id/terminate/response', {id: @receiver_session.sharer_id, response: false}
			@my_Session_User = SessionUser.find_by(receiver: @receiver, session: @receiver_session)
			expect(@my_Session_User.receiver_ended).to eq(false)
		end
	end
end
