describe 'Handshakes' do
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

	describe '/sessions/:id/pickup/request' do
      it 'should update the database properly' do
        session = FactoryGirl.create(:session_with_driver)
        post "/sessions/#{session.id}/pickup/request"
        onDB = Session.find(session.id)
        expect(onDB.requested_pickup).to eq true
      end
      
      it 'should return a 204 response' do
        session = FactoryGirl.create(:session_with_driver)
        post "/sessions/#{session.id}/pickup/request"
        expect(last_response.status).to eq 204
      end

      it 'should return a 500 error for a session with no driver' do
        session = FactoryGirl.create(:session) #session with no driver
        post "/sessions/#{session.id}/pickup/request"
        expect(last_response).to_not be_ok
      end
	end		

	describe 'sessions/:id/pickup/response' do
      it 'should return a 500 error when passed an invalid value for response' do
        session = FactoryGirl.create(:session_with_driver)
        post "/sessions/#{session.id}/pickup/response", { response: 'Nottb0013An', eta: Faker::Time.forward(1) }.to_json
        expect(last_response).to_not be_ok
      end

      it 'should return a 500 error for an invalid eta' do
        session = FactoryGirl.create(:session_with_driver)
        post "/sessions/#{session.id}/pickup/response", { response: true, eta: DateTime.now }.to_json
        expect(last_response).to_not be_ok
      end
  
      it 'should update the eta value in the database' do
        session = FactoryGirl.create(:session_with_driver)
        time = Faker::Time.forward(1)
        post "/sessions/#{session.id}/pickup/response", { response: true, eta: time }.to_json
        onDB = Session.find(session.id)
        expect(onDB).to have_attributes(driver_eta: time)
      end

      it 'should suceed without an eta value' do
        session = FactoryGirl.create(:session_with_driver)
        post "/sessions/#{session.id}/pickup/response", { response: false }.to_json
        expect(last_response).to_not be_ok
      end
      
      it 'should not update the database when response is false' do
        session = FactoryGirl.create(:session_with_driver)
        time = Faker::Time.forward(1)
        post "/sessions/#{session.id}/pickup/response", { response: false, eta: time }.to_json
        onDB = Session.find(session.id)
        expect(onDB).to have_attributes(driver_eta: session.driver_eta)
      end
	end
    
end
