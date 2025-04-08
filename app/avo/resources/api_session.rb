class Avo::Resources::ApiSession < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :ip_address, as: :text
    field :user_agent, as: :text
    field :endpoint, as: :text
    field :request_params, as: :code, language: "javascript" do |model|
      if ApiSession.find(params[:id]).request_params.present?
        JSON.pretty_generate(ApiSession.find(params[:id]).request_params.as_json)
      end
    end
  end
end
