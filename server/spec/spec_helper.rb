# Run all tests in the :test environment
ENV['RACK_ENV'] = 'test'
# Rack's HTTP mocking for tests
require 'rack/test'
# Database management for testing
require 'database_cleaner'
# The Sinatra app
require File.expand_path '../../server.rb', __FILE__
# Factory girl generated models nicely
require 'factory_girl'
# Faker generates random data nicely
require 'faker'
# The factory_girl factories for the app
require_relative 'factories'


# Define an instance of the server for the tests
def app
  Sinatra::Application
end

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random
  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed


  # Include the Sinatra mixins
  config.include Rack::Test::Methods
  # Include the model factory methods
  config.include FactoryGirl::Syntax::Methods


  # Use transactions to make resetting the database easier
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  # Reset the database after every test
  config.before(:each)  { DatabaseCleaner.start }
  config.after(:each)   { DatabaseCleaner.clean }
end
