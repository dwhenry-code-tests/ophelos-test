module Security::Jwt
  TOKEN_NAME = "Authorization"
  HASHING_ALGORITHM = "HS256"
  TTL_MINUTES = ENV.fetch("TTL_MINUTES", 5).to_i

  def add_jwt_to_response_headers!
    if current_user.present?
      response.headers[TOKEN_NAME] = generate_jwt
    end
  end

  def hmac_secret_key
    ENV["HMAC_SECRET_KEY"]
  end

  def generate_jwt
    JWT.encode(exp_payload, hmac_secret_key, HASHING_ALGORITHM)
  end

  def decode_token(token)
    JWT.decode token, hmac_secret_key, true, { algorithm: HASHING_ALGORITHM }
  end

  def exp_payload
    { user_id: current_user.id, exp: token_expiry_time }
  end

  def token_expiry_time
    Time.now.to_i + TTL_MINUTES * 60
  end

  class Generator
    include Security::Jwt
    attr_reader :current_user

    def initialize(user)
      @current_user = user
    end
  end
end
