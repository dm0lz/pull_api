class ApiSession < ApplicationRecord
  belongs_to :user
  validates :endpoint, presence: true
  after_create :set_credit

  private
  def set_credit
    user.update!(api_credit: user.api_credit - api_endpoint_credit[endpoint])
  end

  def api_endpoint_credit
    {
      "api/v1/serp" => 1,
      "api/v1/hf_inference" => 3,
      "api/v1/scrap_web_page" => 1,
      "api/v1/scrap_web_pages" => 1,
      "api/v1/scrap_domain" => 2,
      "api/v1/company_domain" => 2,
      "api/v1/domain_emails" => 2,
      "api/v1/analyze_web_page" => 2,
      "api/v1/analyze_serp" => 2,
      "api/v1/speech_to_text" => 2,
      "api/recaptcha_solver" => 0,
      "api/v1/hf_models" => 0
    }
  end
end
