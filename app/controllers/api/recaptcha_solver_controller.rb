class Api::RecaptchaSolverController < Api::V1::BaseController
  after_action :record_request
  def image_classification_challenge
    @solver = Ai::Recaptcha::ImageClassificationService.new(
      img_base64: recaptcha_solver_params[:img_base64],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword
    )
    @image_classification_challenge_solution = @solver.call
  end

  def images_classification_challenge
    @solver = Ai::Recaptcha::ImagesClassificationService.new(
      base64_images: recaptcha_solver_params[:base64_images],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword
    )
    @images_classification_challenge_solution = @solver.call
  end

  def object_localization_challenge
    @solver = Ai::Recaptcha::ImageSegmentationService.new(
      # @solver = Ai::Recaptcha::ObjectLocalizationService.new(
      img_base64: recaptcha_solver_params[:img_base64],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword
    )
    @object_localization_challenge_solution = @solver.call
  end

  private
  def recaptcha_solver_params
    params.permit(:img_base64, :tiles_nb, :keyword, base64_images: [ :base64, :tiles_nb, :is_grid, :index ])
  end

  def cleaned_keyword
    recaptcha_solver_params[:keyword].singularize.sub(/\Aan? /, "").downcase
  end

  def record_request
    RecaptchaChallenge.create!(
      img_base64: recaptcha_solver_params[:img_base64],
      base64_images: recaptcha_solver_params[:base64_images],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: cleaned_keyword,
      challenge: params[:action],
      python_script: @solver.python_script,
    )
  end
end
