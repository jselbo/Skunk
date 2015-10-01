require 'digest'

# POST /users/create
# {
#   "name": "username",
#   "email": "user email",
#   "password": "userpassword",
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
    name: params['name'],
    email: params['email'],
    password: params['password']
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
#   "name": "username",
#   "password": "userpassword"
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
  # If the user does not exist, return a 404
  halt(404) unless @user
  # If they do exist, return their ID.
  { user_id: @user.id }.to_json
end
