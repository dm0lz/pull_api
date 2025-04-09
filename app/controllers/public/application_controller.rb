class Public::ApplicationController < ApplicationController
  allow_unauthenticated_access
  before_action :set_session_id
  attr_reader :session_id
  layout "public_application"

  private
  def set_session_id
    @session_id = cookies.encrypted["_pull_api_session"]["session_id"] rescue nil
  end
end
