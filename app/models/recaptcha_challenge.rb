class RecaptchaChallenge < ApplicationRecord
  after_save :create_python_file

  def create_python_file
    File.open(Rails.root.join("python_scripts", "recaptcha_challenge_#{id}.py"), "w") do |file|
      file.write(python_script.gsub(/^ {6}/, ""))
    end
  end
end
