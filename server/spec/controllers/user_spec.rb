describe 'Users Controller' do
  context '/users/create' do
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
      it "should return \"422 Unprocessable Entity\" when #{column} is omitted" do
        user_attributes = FactoryGirl.attributes_for(:user)
        user_attributes.delete(column)
        post '/users/create', user_attributes.to_json
        expect(last_response.status).to eq(422)
      end
    end
  end


  context '/users/login' do
    before :each do
      @user_attributes = FactoryGirl.attributes_for(:user)
      @user = User.create(@user_attributes)
    end

    it 'should return "200 OK" for a valid login attempt' do
      post '/users/login', @user_attributes.to_json
      expect(last_response).to be_ok
    end

    it 'should return a User object for a valid login attempt' do
      post '/users/login', @user_attributes.to_json
      expect(last_response.body).to eq(@user.to_json)
    end

    it 'should not include a password in the response' do
      post '/users/login', @user_attributes.to_json
      expect(last_response.body).not_to match(/"password":/)
    end

    it 'should return "404 Not Found" for a user that does not exist' do
      post '/users/login', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.status).to eq(404)
    end

    it 'should return "401 Unauthorized" for an incorrect password' do
      @user_attributes[:password] = @user_attributes[:password] + 'not correct'
      post '/users/login', @user_attributes.to_json
      expect(last_response.status).to eq(401)
    end

    [:phone_number, :password].each do |column|
      it "should return \"422 Unprocessable Entity\" when #{column} is omitted" do
        user_attributes = FactoryGirl.attributes_for(:user)
        user_attributes.delete(column)
        post '/users/login', user_attributes.to_json
        expect(last_response.status).to eq(422)
      end
    end
  end
end
