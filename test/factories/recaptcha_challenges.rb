FactoryBot.define do
  factory :recaptcha_challenge do
    img_base64 { "MyText" }
    base64_images { "MyText" }
    tiles_nb { 1 }
    keyword { "MyString" }
  end
end
