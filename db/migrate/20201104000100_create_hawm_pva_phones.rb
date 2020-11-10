class CreateHawmPvaPhones < ActiveRecord::Migration[6.0]
  def change
    create_table :hawm_pva_phones do |t|
      t.belongs_to :user, index: { unique: true }

      t.string :country_code
      t.string :phone_number
      t.timestamps

      t.index [:country_code, :phone_number], unique: true
    end
  end
end
