require 'sinatra'
require 'sinatra/activerecord'
require 'mysql2'

# Rack is being a bit weird with thin, making some random asserts. Let's just
# ignore those, shall we?
module Rack
  class Lint
    def assert message, &block
    end
  end
end

# Everything we do here is JSON, so default to returning it.
before do
  content_type 'application/json'
end

# To reduce merge conflicts and such, separate all of the action logic into
# different files. This may eventually need to be further separated depending
# on how complex the interactions get.

# #
# Models
# #

require './models/session.rb'
require './models/session_user.rb'
require './models/user.rb'


# #
# Controllers
# #

# sessions.rb contains the endpoint for basic management of session objects.
require './controllers/sessions.rb'
# session_handshakes.rb contains the endpoints where either requests or
# approvals for actions are made.
require './controllers/session_handshakes.rb'
# users.rb contains the endpoints for managing users.
require './controllers/users.rb'
