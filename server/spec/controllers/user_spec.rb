describe 'Users Controller' do
  context '#create' do

    it 'should return "200 OK" when a User is created' do
      post '/users/create', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.status).to eq(200)
    end

    it 'should return an ID and "created: true" when a User is created' do
      post '/users/create', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.body).to match(/"user_id":\w+,"created":true/)
    end

    it 'should return an ID and "created: false" when a User is exists' do
      user_attributes = FactoryGirl.attributes_for(:user)
      User.create(user_attributes)
      post '/users/create', user_attributes.to_json
      expect(last_response.body).to match(/"user_id":\w+,"created":false/)
    end

    [:first_name, :last_name, :phone_number, :password].each do |column|
      it "should return a \"422 Unprocessable Entity\" when #{column} is omitted" do
        user_attributes = FactoryGirl.attributes_for(:user)
        user_attributes.delete(column)
        post '/users/create', user_attributes.to_json
        expect(last_response.status).to eq(422)
      end
    end
  end
end
