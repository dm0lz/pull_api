class CreateRecaptchaChallenges < ActiveRecord::Migration[8.0]
  def change
    create_table :recaptcha_challenges do |t|
      t.text :img_base64
      t.text :base64_images, array: true, default: []
      t.integer :tiles_nb
      t.string :keyword
      t.string :challenge
      t.text :python_script

      t.timestamps
    end
  end
end
