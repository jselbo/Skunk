describe 'Levis_Session_Handshakes Controller' do
	describe '/sessions/:id/terminate/request' do
		before :each do
			@premade_receivers = (0..5).map{FactoryGirl.create(:user)}
		end
		it 'returns 204 for one receiver getting sent a termination request' do
			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/request", {receivers: [@premade_receivers[0].id]}.to_json
			expect(last_response.status).to eq(204)
		end
		
		it 'returns 204 for multiple receivers getting sent a termination request' do
			@premade_sessions = (0..5).map {FactoryGirl.create(:session)}
			@premade_sessions.each do |sess|
				sess.receivers << FactoryGirl.create(:user)
				sess.receivers << FactoryGirl.create(:user)
			end
			
			post "/sessions/#{@premade_sessions[1].id}/terminate/request", {receivers: [@premade_sessions[1].receivers.at(0).id, @premade_sessions[1].receivers.at(1).id]}.to_json
			expect(last_response.status).to eq(204)
		end
		
		it 'updates the SessionUsers so that sharer_ended is true for the one receiver that the sharer wishes to stop sharing with' do

			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/request", {receivers: [@premade_receivers[0].id]}.to_json
			@test = SessionUser.find_by(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id)
			expect(@test.sharer_ended).to eq(true)
		end
		
		it 'updates the SessionUsers so that sharer_ended is true for all receivers that the sharer wishes to stop sharing with' do
			
			@premade_sessions = (0..2).map {FactoryGirl.create(:session)}
                        @premade_sessions[0].receivers << FactoryGirl.create(:user)
                        @premade_sessions[0].receivers << FactoryGirl.create(:user)
                        @premade_sessions[1].receivers << @premade_sessions[0].receivers.at(1)
                        @premade_sessions[1].receivers << FactoryGirl.create(:user)
                        @premade_sessions[1].receivers << FactoryGirl.create(:user)
                        @premade_sessions[2].receivers << @premade_sessions[1].receivers.at(2)
                        @premade_sessions[2].receivers << @premade_sessions[0].receivers.at(0)
 
                        post "/sessions/#{@premade_sessions[1].id}/terminate/request", {receivers: [@premade_sessions[1].receivers.at(0).id, @premade_sessions[1].receivers.at(1).id]}.to_json
			@test = [SessionUser.find_by(session: @premade_sessions[1], receiver_id: @premade_sessions[1].receivers.at(0).id), SessionUser.find_by(session: @premade_sessions[1], receiver_id: @premade_sessions[1].receivers.at(1).id)]

			expect(@test.map(&:sharer_ended)).not_to include(false)
		end

		it 'does not update the SessionUsers if the corresponding receiver is not selected to stop receiving updates' do
			
			@premade_sessions = (0..2).map {FactoryGirl.create(:session)}
                        @premade_sessions[0].receivers << FactoryGirl.create(:user)
                        @premade_sessions[0].receivers << FactoryGirl.create(:user)
                        @premade_sessions[1].receivers << @premade_sessions[0].receivers.at(1)
                        @premade_sessions[1].receivers << FactoryGirl.create(:user)
                        @premade_sessions[1].receivers << FactoryGirl.create(:user)
                        @premade_sessions[2].receivers << @premade_sessions[1].receivers.at(2)
                        @premade_sessions[2].receivers << @premade_sessions[0].receivers.at(0)
 
                        post "/sessions/#{@premade_sessions[1].id}/terminate/request", {receivers: [@premade_sessions[1].receivers.at(0).id, @premade_sessions[1].receivers.at(1).id]}.to_json
			@test = SessionUser.find_by(session: @premade_sessions[1], receiver_id: @premade_sessions[1].receivers.at(2).id)
			expect(@test.sharer_ended).to eq(nil)
		end

		
		it 'returns 500 if no receivers are provided' do
			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/request", {receivers: []}
			expect(last_response.status).to eq(500)
		end
		
		
	end
	
	describe '/sessions/:id/terminate/response' do
		
		before :each do
			@premade_receivers = (0..5).map{FactoryGirl.create(:user)}
		end

	
		it 'returns 204 if response is true' do
			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			SessionUser.where(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id).update_all(sharer_ended: true)
			header 'Skunk_UserID', @premade_receivers[0].id 
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/response", {:response=>true}.to_json
			expect(last_response.status).to eq(204)
		end
		
		it 'returns 204 if response is false' do
			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			SessionUser.where(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id).update_all(sharer_ended: true)
			header 'Skunk_UserID', @premade_receivers[0].id 
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/response", {:response=>false}.to_json
			expect(last_response.status).to eq(204)
		end
		
		it 'updates the session_user if response is true' do
			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			SessionUser.where(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id).update_all(sharer_ended: true)
			header 'Skunk_UserID', @premade_receivers[0].id 
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/response", {:response=>true}.to_json
			@sess_user = SessionUser.find_by(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id)
			expect(@sess_user.receiver_ended).to eq(true)	
		end
		
		it 'does not update session_user if response is false' do
			@premade_receivers[0].sessions << FactoryGirl.create(:session)
			SessionUser.where(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id).update_all(sharer_ended: true)
			header 'Skunk_UserID', @premade_receivers[0].id 
			post "/sessions/#{@premade_receivers[0].sessions.at(0).id}/terminate/response", {:response=>false}.to_json
			@sess_user = SessionUser.find_by(session: @premade_receivers[0].sessions.at(0), receiver_id: @premade_receivers[0].id)
			expect(@sess_user.receiver_ended).to eq(nil)
		end	
	end
end
