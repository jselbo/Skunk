# IMPORTANT NOTE ABOUT SESSION REQUESTS:
#
# All requests for sessions require an HTTP header formatted as:
#
#   Skunk-UserID: <user_id>
#
# Requests which do not provide this header will be automatically be rejected
# with a response code of 401 Not Authorized.



# POST /sessions/:id/terminate/request
# {
#   "receivers": [ <user_id>, <user_id>, ... ]
# }
# -> 204 No Content
# -> 500 Internal Server Error
#
# This endpoint is used by the sharer to notify a receiver (or multiple
# receivers) that they would like to stop sharing their location *before*
# it automatically terminates (either by time or location information).
#
# Hitting this endpoint does NOT mean that the sharer is free to stop sharing.
# Instead, the sharer must wait for their heartbeat response to say that the
# session has been terminated before halting.
#
# On success, returns a 204 No Content, since the sharer already knows the
# information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/:id/terminate/request' do
  # Get the receivers from the request
	receivers = params[:receivers]
	# Get the session
	@session = Session.find(params[:id])
  # Cycle through session_users to mark if the sharer ended the session
  # receivers.each do |rid|
  #   @session_user = SessionUser.find_by(receiver: rid, session: @session)
  #   @session_user.sharer_ended = true
  # end
  #
  # NOTE: #update_all is a nice method to handle this.
  SessionUser.where(receiver_id: receivers).update_all(sharer_ended: true)
	#TODO Push notification to notify receivers of sharer termination

	return 204
end

# POST /sessions/:id/terminate/response
# {
#   "response": true | false
# }
# -> 204 No Content
# -> 500 Internal Server Error
#
# This endpoint is used by receivers to indicate that they are okay with the
# sharing ending the session prematurely. This is only effective following a
# termination request from the sharer.
#
# On success, returns a 204 No Content, since the sharer already knows the
# information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/:id/terminate/response' do
	# Get user id for the receiver
	@user = User.find(headers["HTTP_SKUNK_USERID"])
  # Get the response from the request
	response = params[:response]
	# Get the session
	@session = Session.find(params[:id])
	# Get the session_user to mark if the receiver approved
  @session_user = SessionUser.find_by(receiver: @user, session: @session)
	# If response is true, then mark receiver ended as true
	# If not keep it false
	if response
		@session_user.receiver_ended = true
	end

	return 204
end

# PUT /sessions/:id/pickup/request
# { }
# -> 204 No Content
# -> 500 Internal Server Error
#
# This endpoint is used by the sharer to notify the driver for the session
# that they are ready to be picked up. No additional information is required,
# so the body of the request is left blank.
#
# On success, returns a 204 No Content, since the sharer already knows the
# information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
put '/sessions/:id/pickup/request' do
  # Get the session
  @session = Session.find(params[:id])
  # If the driver has been specified for this session, send notification to the driver
  if @session.driver
  	# TODO: will drivers be stored as users like this?
  	# Ensure that driver actually exists in the database
  	begin
  		driver = Users.find(@session.driver_id)
  	rescue
  		halt 500, 'Invalid driver_id for this session.'
  	end

  	# TODO: Send notification to receiver.

  # No driver was specified for this session
  else
  	halt 500, 'No driver exists for this session.'
  end

  # Remember that the user has requested a pickup
  @session.update(requested_pickup: true)

  return 204
end

# POST /sessions/:id/pickup/response
# {
#   "response": true | false,
#   "eta": <ISO 8601 duration string>
# }
# -> 204 No Content
# -> 500 Internal Server Error
#
# This endpoint is used by the driver for the session to indicate that they
# have acknowledged the pickup request and provide the sharer with an
# estimated pickup time. "eta" is optional, depending on the value of
# "reponse"; if it is provided, it should represent the amount of time
# (following ISO 8601 for duration values) that the driver anticipates will be
# required for them to pick up the sharer.
#
# On success, returns a 204 No Content, since the driver already knows the
# information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/:id/pickup/response' do
  # Get the session
  session = Session.find(params[:id])
  # If an ETA is provided, update session with the eta
  if params[:response] # TODO: how will ruby handle invalid input
  	# Ensure ETA is in correct format
  	begin
  		# Try parsing eta parameter
  		duration = DateTime.iso8601(params[:eta])
  		# Convert from duration to concrete time
  		eta = DateTime.now + duration
  		# Update ETA on session object
  		session.driver_eta = eta
  	# ETA is not in proper format.
  	rescue
  		# Do nothing.
  		# TODO: Should we send a message that eta failed?
  	end
  end

  return 204
end

# POST /sessions/:id/driver/response
# {
#   "response": true | false
# }
# -> 204 No Content
# -> 500 Internal Server Error
#
# This endpoint is used by receivers to indicate that they are willing to be
# the driver for a sharer who is requesting a driver to pick them up. The
# driver for the session will be chosen on a first-come, first-serve basis,
# and will be recorded in the session object as soon as this endpoint is
# successfully hit.
#
# On success, returns a 204 No Content, since the receiver already knows the
# information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/:id/driver/response' do
  # If the receiver indicated that they want to be the driver...
  if params[:response]
    # find the session they are responding to,
    session = Session.find(params[:id])
    # and update it with their response.
    session.update(driver_id: request.env['HTTP_SKUNK_USERID'])
    # Then, return a 204 indicating that they request has suceeded
    halt 204
  end
  # Otherwise, nothing happens
end
