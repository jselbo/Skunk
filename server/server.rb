require 'sinatra'
require 'sinatra/activerecord'


# To reduce merge conflicts and such, separate all of the action logic into
# different files. This may eventually need to be further separated depending
# on how complex the interactions get.

# sessions.rb contains the endpoint for basic management of session objects.
require './controllers/sessions.rb'
# session_handshakes.rb contains the endpoints where either requests or
# approvals for actions are made.
require './controllers/session_handshakes.rb'
# users.rb contains the endpoints for managing users.
require './controllers/users.rb'
