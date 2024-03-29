FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.phone_number }
    password { Faker::Internet.password }
  end
	
  factory :session do
	association :sharer, factory: :user, strategy: :build

    needs_driver { false } 
#    driver_id nil
    
    start_time { DateTime.now  }
    is_time_based { true }
    end_time { Faker::Time.backward() }    
    
    destination nil
    terminated { false }

    #TODO: define the time threshold in the session object probably
    last_updated { Faker::Time.between(15.minutes.ago, Time.now) }
    requested_pickup { false }
    driver_eta { Faker::Time.forward()  }
    current_location "#{ Faker::Address.latitude},#{Faker::Address.longitude }" 

    factory :session_with_destination do 
        is_time_based { false }
        destination "#{ Faker::Address.latitude},#{Faker::Address.longitude }" 
    end

    factory :session_with_driver do
        association :driver, factory: :user#, strategy: :build
        needs_driver { true } 
    end
  end
end
