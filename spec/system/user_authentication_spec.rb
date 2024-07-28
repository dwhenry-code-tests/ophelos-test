require "rails_helper"

RSpec.describe "User Authentication" do
  it "can create a new user" do
    expect { post '/v1/users', params: { user: { email: 'test@test.com' } } }.to change(User, :count).by(1)
    expect(response.status).to eq(200)
  end

  it "returns a new jwt token for the user" do
    jwt_token = SecureRandom.uuid
    expect(JWT).to receive(:encode).and_return(jwt_token)

    post '/v1/users', params: { user: { email: 'test@test.com' } }
    expect(JSON.parse(response.body)['token']).to eq(jwt_token)
  end

  context "when user email already exists" do
    it "returns a 409 status code" do
      User.create(email: 'test@test.com')

      post '/v1/users', params: { user: { email: 'test@test.com' } }
      expect(response.status).to eq(409) # is this is correfct response code? out of scope as this is for the test only
    end
  end

  it "can return a new token for an existing user" do
    User.create(email: 'test@test.com')
    jwt_token = SecureRandom.uuid
    expect(JWT).to receive(:encode).and_return(jwt_token)

    get '/v1/users', params: { email: 'test@test.com' }
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['token']).to eq(jwt_token)
  end

  it "returns a 409 status code when user does exist" do
    get '/v1/users', params: { email: 'test@test.com' }
    expect(response.status).to eq(409)
    expect(JSON.parse(response.body)['token']).to be_nil
  end
end
