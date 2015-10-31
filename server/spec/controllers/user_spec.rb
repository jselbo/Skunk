describe "Controllers" do
  include Rack::Test::Methods  #<---- you really need this mixin

  def app
    Sinatra::Application
  end

  context "User" do
    it "should allow accessing the home page" do
      get '/sessions/'
      expect(last_response).to be_ok
    end
  end
end
