describe 'Users Controller' do
  context '#create' do
    it 'should return "200 OK" when a User is created' do
      post '/users/create', FactoryGirl.attributes_for(:user).to_json
      expect(last_response).to be_ok
    end

    it 'should return a User ID when a User is created' do
      post '/users/create', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.body).not_to be_empty
    end
  end
end
