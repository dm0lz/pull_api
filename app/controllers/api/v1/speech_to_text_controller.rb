class Api::V1::SpeechToTextController < Api::V1::BaseController
  # @summary Speech to text transcription
  # @auth [bearer]
  # @parameter audio_url(query) [!String] The url of the audio file to transcribe
  # @response Validation errors(401) [Hash{error: String}]
  # @response Validation errors(403) [Hash{error: String}]
  # @response Validation errors(422) [Hash{error: String}]
  def create
    unless speech_to_text_params[:audio_url]
      return render json: { error: "audio_url is required" }, status: :unprocessable_entity
    end

    @text = Ai::SpeechToText::TranscriptionService.new(
      audio_url: speech_to_text_params[:audio_url]
    ).call
  end

  private
  def speech_to_text_params
    params.permit(:audio_url)
  end
end
