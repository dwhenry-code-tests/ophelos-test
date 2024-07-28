require "rails_helper"

RSpec.describe Security::Jwt do
  let(:user) { double(User, id: 12) }
  let(:klass) do
    Class.new do
      include Security::Jwt
      attr_reader :current_user

      def initialize(user)
        @current_user = user
      end
    end
  end
  subject { klass.new(user) }

  it "includes the expected fields in the encoded payload" do
    expect(subject.exp_payload).to include(
      user_id: 12,
      exp: instance_of(Integer)
    )
  end

  it "can encode and decode the payload" do
    # need to freeze time as the expiry field is not memorised
    travel_to(Time.now) do
      expect(subject.decode_token(subject.generate_jwt).first).to eq(subject.exp_payload.stringify_keys)
    end
  end

  it "encodes the message to the same token every time (assuming the packet is the same)" do
    travel_to(Time.now) do
      expect(subject.generate_jwt).to eq(subject.generate_jwt)
    end
  end
end
