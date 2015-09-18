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
post '/sessions/:id/pickup/request' do
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
end
