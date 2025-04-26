class Avo::Resources::RecaptchaChallenge < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :img_base64, as: :textarea
    field :base64_images, as: :textarea
    field :tiles_nb, as: :number
    field :keyword, as: :text
    field :python_script, as: :textarea
  end
end
