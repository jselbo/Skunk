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
	receiver_ids = params['receivers']
	# Get the session
	@session = Session.find(params['id'])
  # Mark that the sharer has ended the session
  SessionUser.where(session: @session, receiver_id: receiver_ids).update_all(sharer_ended: true)
  # Notify the given receivers that the sharer wants to stop sharing with them.
  PushNotification.session_ending @session, User.where(id: receiver_ids)

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
	@user = User.find(request.env['HTTP_SKUNK_USERID'])
  # Get the response from the request
	response = params['response']
	# Get the session
	@session = Session.find(params['id'])
	# Get the session_user to mark if the receiver approved
  @session_user = SessionUser.find_by(receiver: @user, session: @session)
  # If response is true, then mark receiver ended as true
  @session_user.update(receiver_ended: true) if response
  # If all of the receivers for the session have approved termination, mark
  # it as terminated.
  if @session.session_users.all?{ |su| su.receiver_ended }
    @session.update(terminated: true)
  end

	return 204
end

# POST /sessions/:id/pickup/request
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
post '/sessions/:id/pickup/request' do
  # Get the session
  @session = Session.find(params['id'])
  # If the session does not have a driver,
  if not @session.driver
    halt(500)
  end

  # Notify the driver for the session that the sharer has requested a pickup.
  PushNotification.pickup_request @session
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
# "reponse"; if it is provided, it should represent the time (following ISO
# 8601 standard) at which the driver anticipates they will be able to pick up
# the sharer.
#
# On success, returns a 204 No Content, since the driver already knows the
# information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
post '/sessions/:id/pickup/response' do
  # Get the session
  @session = Session.find(params['id'])
  # If the user accepted the request,
  if params['response']
    # set their ETA,
		@session.update(driver_eta: DateTime.iso8601(params['eta']))
    # and notify the sharer.
    PushNotification.pickup_response @session
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
  if params['response']
    # find the session they are responding to,
    session = Session.find(params['id'])
    # and update it with their response.
    session.update(driver_id: request.env['HTTP_SKUNK_USERID'])
    # Then, return a 204 indicating that they request has suceeded
    halt 204
  end
  # Otherwise, nothing happens
end
