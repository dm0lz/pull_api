class Api::V1::RecaptchaSolverController < Api::V1::BaseController
  # @summary Solve Recpatcha
  # @auth [bearer]
  # @parameter url(query) [!String] The url of the image
  # @parameter tiles_nb(query) [!String] The number of tiles
  # @parameter keyword(query) [!String] The keyword to search for
  # @response Validation errors(401) [Hash{error: String}]
  # @response Validation errors(403) [Hash{error: String}]
  # @response Validation errors(422) [Hash{error: String}]
  def create
    @solution = Ai::Recaptcha::SolverService.new(
      img_base64: recaptcha_solver_params[:img_base64],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: recaptcha_solver_params[:keyword].singularize
    ).call
  end

  def step_2
    @solution2 = Ai::Recaptcha::Solver2Service.new(
      base64_images: recaptcha_solver_params[:base64_images],
      tiles_nb: recaptcha_solver_params[:tiles_nb],
      keyword: recaptcha_solver_params[:keyword].singularize
    ).call
  end

  private
  def recaptcha_solver_params
    params.permit(:img_base64, :tiles_nb, :keyword, base64_images: [ :base64, :tiles_nb, :is_grid, :index ])
  end
end
