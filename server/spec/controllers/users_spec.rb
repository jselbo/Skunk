describe 'Users Controller' do
  context '/users/create' do
    it 'returns "200 OK" when a User is created' do
      post '/users/create', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.status).to eq(200)
    end

    it 'returns an ID and "created: true" when a User is created' do
      post '/users/create', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.body).to match(/"user_id":\w+,"created":true/)
    end

    it 'returns an ID and "created: false" when a User is exists' do
      user_attributes = FactoryGirl.attributes_for(:user)
      User.create(user_attributes)
      post '/users/create', user_attributes.to_json
      expect(last_response.body).to match(/"user_id":\w+,"created":false/)
    end

    [:first_name, :last_name, :phone_number, :password].each do |column|
      it "returns \"422 Unprocessable Entity\" when #{column} is omitted" do
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

    it 'returns "200 OK" for a valid login attempt' do
      post '/users/login', @user_attributes.to_json
      expect(last_response).to be_ok
    end

    it 'returns a User object for a valid login attempt' do
      post '/users/login', @user_attributes.to_json
      expect(last_response.body).to eq(@user.to_json)
    end

    it 'does not include a password in the response' do
      post '/users/login', @user_attributes.to_json
      expect(last_response.body).not_to include('"password":')
    end

    it 'returns "404 Not Found" for a user that does not exist' do
      post '/users/login', FactoryGirl.attributes_for(:user).to_json
      expect(last_response.status).to eq(404)
    end

    it 'returns "401 Unauthorized" for an incorrect password' do
      @user_attributes[:password] = @user_attributes[:password] + 'not correct'
      post '/users/login', @user_attributes.to_json
      expect(last_response.status).to eq(401)
    end

    [:phone_number, :password].each do |column|
      it "returns \"422 Unprocessable Entity\" when #{column} is omitted" do
        user_attributes = FactoryGirl.attributes_for(:user)
        user_attributes.delete(column)
        post '/users/login', user_attributes.to_json
        expect(last_response.status).to eq(422)
      end
    end
  end

  context '/users/find' do
    before :all do
      @users = (0..10).map { FactoryGirl.create(:user) }
    end

    it 'returns an array of User objects that match the parameters' do
      selected_users = @users[0..5]
      phone_numbers = selected_users.map(&:phone_number)
      post '/users/find', { phone_number: phone_numbers }.to_json
      expect(last_response.body).to eq(selected_users.to_json)
    end

    it 'returns a blank array when no Users match the parameters' do
      post '/users/find', { phone_number: [] }.to_json
      expect(last_response.body).to eq('[]')
    end

    it 'does not include passwords in the response' do
      selected_users = @users[0..5]
      phone_numbers = selected_users.map(&:phone_number)
      post '/users/find', { phone_number: phone_numbers }.to_json
      expect(last_response.body).not_to include('"password":')
    end

    it 'only filters results by phone number' do
      filter_criteria = {
        phone_number: @users.map(&:phone_number),
        first_name: @users.first.first_name
      }
      post '/users/find', filter_criteria.to_json
      expect(last_response.body).to eq(@users.to_json)
    end
  end
end
