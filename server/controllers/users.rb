# POST /users/create
# {
#   "name": "username",
#   "email": "user email",
#   "password": "userpassword",
#   ...
# }
# -> 200 OK <user_id>
# -> 500 Internal Server Error
#
# This endpoint is hit whenever a new user registers to use the app. The body
# of the request contains any information that the user needs to identify
# themselves in the system (the contents of which is yet to be determined).
#
# On success, returns the unique ID for the user (a SHA-2 Hash value).
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/users/create' do
end
