# IMPORTANT NOTE ABOUT SESSION REQUESTS:
#
# All requests for sessions require an HTTP header formatted as:
#
#   Skunk-UserID: <user_id>
#
# Requests which do not provide this header will be automatically be rejected
# with a response code of 401 Not Authorized.



# GET /sessions
#
# -> 200 OK [ {session_object}, {session_object} ]
# -> 500 Internal Server Error
#
# This endpoint is used to initialize the receiver side of the app by
# providing all necessary information for all of the sessions that the user is
# a receiver in.
#
# On success, returns an array of Session objects.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
get '/sessions' do
	@user = User.find(request.env["HTTP_SKUNK_USERID"])

	if @user.active_sessions.empty?
		halt 500
	else
		@user.active_sessions.to_json
	end
end


# GET /sessions/:id
#
# -> 200 OK {session_object}
# -> 304 Not Modified
# -> 401 Not Authorized
# -> 404 Not Found
#
# This endpoint is used to update the receiver's view of an individual sharer
# by returning the current session object every time it is requested. This
# is the receiver's heartbeat to the app, meaning they should regularly hit it
# to ensure they have the most up-to-date information.
#
# If the session exists and the user is part of the session, returns the
# session object with the given ID.
# If the session exists, contains the user, and has not changed, returns a
# 304 Not Modified to save bandwidth.
# If the session exists, but the user is NOT part of the session, returns a
# 401 Not Authorized.
# If the session does not exist, returns a 404 Not Found.
get '/sessions/:id' do
	begin
		@session = Session.find(params['id'])
	rescue ActiveRecord::RecordNotFound
		halt 404
	end
	@user = User.find(request.env['HTTP_SKUNK_USERID'])
	@session_user = SessionUser.find_by(receiver: @user, session: @session)

	halt(404) unless @session

  # The amount of time (seconds) that is allowed between updates
  TIME_BREAK = 15*60
  # If more than TIME_BREAK seconds have passed since the last update
  if DateTime.now > @session.last_updated + TIME_BREAK
    # Send emergency alerts to receivers
  end

	if @session_user && @session_user.active?
		@session.to_json
	else
		halt 401
	end
end


# POST /sessions/create
# {
#   "receivers": [ <user_id>, <user_id>, ... ],
#   "condition": {
#     "type": "time" | "location",
#     "data": <timestamp> | <location_json>
#   },
#   "needs_driver": true | false
# }
# -> 200 OK <session_id>
# -> 500 Internal Server Error
#
# This endpoint is used to initialize a new session when a user begins sharing
# their location. The new session will be created, along with records joining
# each of the listed receivers to the session. The value of "data" in
# "condition" is dependent on the "type". For 'time' conditions, it will be an
# ISO 8601 timestamp representing the time at which the session should end,
# while 'location' conditions will have an ISO 6709 location JSON object as its
# data. "needs_driver" is a boolean representing whether the sharer will be
# requesting a pick up for this session.
#
# On success, returns the ID of the newly-created session.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/create' do
  # Initialize a new Session object
  @session = Session.new(
    sharer: User.find(request.env['HTTP_SKUNK_USERID']),
    needs_driver: params['needs_driver'],
    start_time: DateTime.now,
    last_updated: DateTime.now
  )

  case params['condition']['type']
  # If session is timestamped, set is_time_based to true and store in database
  when 'time'
    puts "\n> Time-type session"
    # Check that timestamp is in iso 8601 format
    begin
      # Set the fields relevant to time-based sessions
      @session.is_time_based = true
      @session.end_time = DateTime.iso8601(params['condition']['data'])
    rescue
      halt 500, 'Improperly formatted timestamp.'
    end
  # If session is location-based set _is_time_based to false and store location
  when 'location'
    puts "\n> Location-type session"
    # Check if location string is in iso 6709 format
    if Session.check_location(params['condition']['data'])
      # Set the fields relevant to location-based sessions
      @session.is_time_based = false
      @session.destination = params['condition']['data'] # should validate type
    else
      halt 500, 'Improperly formatted location string.'
    end
  # Else return an error
  else
    halt 500, 'Invalid condition type.'
  end
  # Populate the sessions_users join table with all the receivers
  @session.receivers = User.where(id: params['receivers'])
  # Save the session to create it in the database with an ID
  @session.save
  # Send notifications to each of the receivers
  PushNotification.session_starting @session
  # Return the new session's id
  { id: @session.id }.to_json
end


# POST /sessions/:id
# {
#   "location": <location_json>
# }
# -> 200 OK
# -> 500 Internal Server Error
#
# This endpoint is used by the sharer to update the session with their current
# location. This is the sharer's heartbeat to the app, meaning they should
# regularly hit it to ensure they are providing the most up-to-date
# information to the receivers.
#
# Failure to check-in within a reasonable amount of time will result in a
# notification being sent to the active receivers, alerting them that the
# sharer has unexpectedly stopped sharing their location.
#
# On success, if the session has changed on the server, returns that session
# object, updated with the sharer's new location.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/:id' do
  # Get the session
  @session = Session.find(params['id'])
  # If location string is incorrectly formatted, return error
  if not Session.check_location(params['location'])
  	halt 500, 'Invalid location string.'
  end
  # Store the new location as the current_location in the database
  @session.update(
    current_location: params['location'],
    last_updated: DateTime.now
  )
  if @session.should_terminate? and not @session.terminated?
    @session.update(terminated: true)
  end
  # Send session object back with new location
  @session.to_json
end
