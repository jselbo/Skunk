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
get  '/sessions/' do
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
get  '/sessions/:id' do
end


# PUT /sessions/:id
# {
#   "location": <location_json>
# }
# -> 200 OK
# -> 204 No Content
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
# If the session has not changed, returns a 204 No Content, since the sharer
# already knows the information that is being updated.
# On error, returns a 500 Internal Server Error with details about what went
# wrong.
put  '/sessions/:id' do
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
end