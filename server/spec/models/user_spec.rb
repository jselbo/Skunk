require 'digest'

describe 'User' do
  it 'is invalid without a first name' do
    expect(FactoryGirl.build(:user, first_name: nil)).not_to be_valid
  end

  it 'is invalid without a last name' do
    expect(FactoryGirl.build(:user, last_name: nil)).not_to be_valid
  end

  it 'is invalid without a phone number' do
    expect(FactoryGirl.build(:user, phone_number: nil)).not_to be_valid
  end

  it 'is invalid without a password' do
    expect(FactoryGirl.build(:user, password: nil)).not_to be_valid
  end

  it 'is valid without a device_id' do
    expect(FactoryGirl.build(:user, password: nil)).to be_valid
  end

  it 'does not allow duplicate phone numbers' do
    FactoryGirl.create(:user, phone_number: '1112223333')
    expect(FactoryGirl.build(:user, phone_number: '1112223333')).not_to be_valid
  end


  it 'automatically encrypts passwords on create' do
    @user = FactoryGirl.build(:user)
    raw_password = @user.password
    @user.save
    expect(@user.password).to eq(User.encrypt(raw_password))
  end

  it 'does not re-encrypt passwords on save' do
    @user = FactoryGirl.create(:user)
    password = @user.password
    @user.save
    expect(@user.password).to eq(password)
  end

  describe '#encrypt_password' do
    it 'overrides the password field with the encrypted password' do
      @user = FactoryGirl.build(:user)
      raw_password = @user.password
      @user.encrypt_password
      expect(@user.password).not_to eq(raw_password)
    end
  end

  describe '#as_json' do
    it 'creates a valid JSON object' do
      @user = FactoryGirl.create(:user)
      json = @user.as_json
      expect(JSON.parse(json)).to be_truty
    end

    it 'does not include password in the result' do
      @user = FactoryGirl.create(:user)
      json = @user.as_json
      expect(json).not_to include(@user.password)
    end
  end


  describe '#full_name' do
    it 'concatenates first and last names' do
      @user = FactoryGirl.build(:user, first_name: 'John', last_name: 'Smith')
      expect(@user.full_name).to eq('John Smith')
    end
  end


  describe 'class method' do
    before :each do
      @users = (0..10).map { FactoryGirl.create(:user) }
      # Create a user with a known password to test credentials with
      @password = 'password'
      @subject = FactoryGirl.create(:user, password: @password)
    end

    describe '::find_by_identity' do
      before :each do
        @criteria = {
          first_name: @subject.first_name,
          last_name: @subject.last_name,
          phone_number: @subject.phone_number
        }
      end

      it 'requires a first name' do
        @criteria.delete(:first_name)
        expect(User.find_by_identity(@criteria)).to be_nil
      end

      it 'requires a last name' do
        @criteria.delete(:last_name)
        expect(User.find_by_identity(@criteria)).to be_nil
      end

      it 'requires a phone number' do
        @criteria.delete(:phone_number)
        expect(User.find_by_identity(@criteria)).to be_nil
      end


      it 'does not allow more than one first name' do
        @criteria[:first_name] = @users.map{ |u| u.first_name }
        expect(User.find_by_identity(@criteria)).to be_nil
      end

      it 'does not allow more than one last name' do
        @criteria[:last_name] = @users.map{ |u| u.last_name }
        expect(User.find_by_identity(@criteria)).to be_nil
      end

      it 'does not allow more than one phone number' do
        @criteria[:phone_number] = @users.map{ |u| u.phone_number }
        expect(User.find_by_identity(@criteria)).to be_nil
      end


      it 'ignores irrelevent search criteria' do
        @criteria[:id] = @users.first.id
        expect(User.find_by_identity(@criteria)).to be_nil
      end

      it 'only returns one result' do
        expect(User.find_by_identity(@criteria)).to be_instance_of(User)
      end

      it 'returns nil if no results are found' do
        @subject.destroy
        expect(User.find_by_identity(@criteria)).to be_nil
      end
    end

    describe '::find_by_credentials' do
      before :each do
        @criteria = {
          phone_number: @subject.phone_number,
          password: @password
        }
      end

      it 'requires a phone number' do
        @criteria.delete(:phone_number)
        expect(User.find_by_credentials(@criteria)).to be_nil
      end

      it 'requires a password' do
        @criteria.delete(:password)
        expect(User.find_by_credentials(@criteria)).to be_nil
      end


      it 'does not allow more than one phone number' do
        @criteria[:phone_number] = @users.map{ |u| u.phone_number }
        expect(User.find_by_credentials(@criteria)).to be_nil
      end

      it 'does not allow more than one password' do
        @criteria[:password] = @users.map{ |u| u.password }
        expect(User.find_by_credentials(@criteria)).to be_nil
      end


      it 'ignores irrelevent search criteria' do
        @criteria[:id] = @users.first.id
        expect(User.find_by_credentials(@criteria)).to be_nil
      end

      it 'only returns one result' do
        expect(User.find_by_credentials(@criteria)).to be_instance_of(User)
      end

      it 'returns nil if no results are found' do
        @subject.destroy
        expect(User.find_by_credentials(@criteria)).to be_nil
      end
    end

    describe '::encrypt' do
      it 'uses SHA2 hexadecimal encryption' do
        password = 'password'
        expect(User.encrypt(password)).to eq(Digest::SHA2.hexdigest(password))
      end
    end
  end
end
