class Api::RecaptchaSolverController < Api::V1::BaseController
  def image_classification_challenge
    @solution = Ai::Recaptcha::ImageClassificationService.new(
      img_base64: recaptcha_solver_params[:img_base64],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword
    ).call
  end

  def images_classification_challenge
    @solution = Ai::Recaptcha::ImagesClassificationService.new(
      base64_images: recaptcha_solver_params[:base64_images],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword
    ).call
  end

  def object_localization_challenge
    @solution = Ai::Recaptcha::ObjectLocalizationService.new(
      img_base64: recaptcha_solver_params[:img_base64],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword
    ).call
  end

  private
  def recaptcha_solver_params
    params.permit(:img_base64, :tiles_nb, :keyword, base64_images: [ :base64, :tiles_nb, :is_grid, :index ])
  end

  def cleaned_keyword
    keyword = recaptcha_solver_params[:keyword].singularize.sub(/\Aan? /, "").downcase
    dict[keyword] || keyword
  end

  def dict
    {
      "taxi" => "van",
      "car" => "van",
      "crosswalk" => "street",
      "bus" => "van",
      "truck" => "van",
      "fire hydrant" => "pedestal",
      "motorcycle" => "moto",
      "bicycle" => "cycle",
      "stair" => "bannister"
    }
  end
end
