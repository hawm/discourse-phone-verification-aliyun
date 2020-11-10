class CreateHawmPvaPhoneTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :hawm_pva_phone_tokens do |t|
      t.belongs_to :user, index: { unique: false }

      t.string :token
      t.string :country_code
      t.string :phone_number
      t.boolean :confirmed
      t.boolean :expired
      t.timestamps

      t.index :token, unique: true
    end
  end
end
