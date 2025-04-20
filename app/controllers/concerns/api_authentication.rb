module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_token!
  end

  private

  def authenticate_api_token!
    if api_token = request.headers["Authorization"]&.split(" ")&.last
      user = User.find_by(api_token: api_token)
      render json: { error: "Insufficient API credit." }, status: :payment_required and return if user&.api_credit <= 0
      # render json: { error: "Rate limit exceeded." }, status: :too_many_requests and return if user.api_sessions.where("created_at >= ?", 1.minute.ago).count >= 5
      Current.api_session = user.api_sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, endpoint: params.permit(:controller)[:controller], request_params: params) if user
    end

    render json: { error: "Invalid API token." }, status: :unauthorized unless Current.user
  end
end
