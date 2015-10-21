require 'digest'

# POST /users/create
# {
#   "first_name": "firstname",
#   "last_name": "lastname",
#   "phone_number": "phonenumber",
#   "password": "userpassword",
#   "device_id": "token"
#   ...
# }
# -> 200 OK <user_id>
# -> 201 Created
# -> 500 Internal Server Error
#
# This endpoint is hit whenever a new user registers to use the app. The body
# of the request contains all of the information that the user needs to
# identify themselves in the system (the contents of which is yet to be
# determined).
#
# On success, returns the unique ID for the user (a SHA-2 Hash value), and
# a boolean indicating whether or not a new user was created.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/users/create' do
  # Filter the parameters from the request JSON
  user_params = {
    first_name:   params['first_name'],
    last_name:    params['last_name'],
    phone_number: params['phone_number'],
    password:     params['password'],
    device_id:    params['device_id']
  }
  # See if the User already exists
  @user = User.find_by_identity user_params
  if @user
    # If they do exist, return their ID and the fact that they already exist
    return { user_id: @user.id, created: false }.to_json
  else
    # Otherwise, create a new User object and save it...
    @user = User.create user_params
    # ...and return the appropriate information
    return { user_id: @user.id, created: true }.to_json
  end
end

# POST /users/login
# {
#   "phone_number": "phonenumber",
#   "password": "userpassword",
#   "device_id": "token"
# }
# -> 200 OK <user_id>
# -> 404 Not Found
# -> 500 Internal Server Error
#
# This endpoint is hit whenever a registered user loads the app. The body
# of the request contains any information that the user needs to verify their
# identity with what is in the system.
#
# On success, returns the unique ID for the user (a SHA-2 Hash value).
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/users/login' do
  # Try to find the user by their credentials
  @user = User.find_by_credentials params
  @user.update(device_id: params[:device_id])
  # If the user does not exist, return a 404
  halt(404) unless @user
  # If they do exist, return their ID.
  { user_id: @user.id }.to_json
end

# POST /users/find
# {
#   "phone_number": ["phonenumber", "phonenumber"]
# }
# -> 200 OK <user_ids>
# -> 500 Internal Server Error
#
# This endpoint is hit whenever a sharer is presented with a list of users who
# who are capable of receiving their location (registered users of the app).
# The body of the request contains the filtering information (primarily phone
# numbers, but potentially names and ids).
#
# On success, returns an array of User objects (id, first_name, last_name,
# and phone_number) which match the filtering criteria.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post 'users/find' do
  User.where(params).to_json
end
