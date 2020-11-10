module HWAM::PVA
  class Phone < ApplicationRecord
    self.table_name = 'hawm_pva_phone'
    belongs_to :user, class_name: '::User'
    validates :country_code, :phone_number, presence: true
    validates :phone_number, uniqueness: {
      scope: :country_code,
    }

    def e164_format(with_space: false)
      '+' + self.country_code + with_spcae ? " " : "" + self.phone_number
    end

    def mask_e164_format(with_space: false)
      '+' + self.country_code + with_space ? " " : "" + self.phone_number.gsub(/.(?=.{4})/, '*')
    end
  end
end
