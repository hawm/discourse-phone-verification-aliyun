module HAWM::PVA
  # read discourse core app/models/email_token.rb
  class PhoneToken < ApplicationRecord
    self.table_name = 'hawm_pva_phone_tokens'
    belongs_to :user, class_name: '::User'
    validates :token, :country_code, :phone_number, presence: true
    validates :token, uniqueness: {
      scope: :user_id,
      case_sensitive: false,
    }

    before_validation(on: :create) do
      self.token ||= PhoneToken.generate_token
    end

    after_crate do
      # expire all previous tokens
      PhoneToken.where(user_id: self.user_id)
        .where("id != ?", self.id)
        .update_all(expired: true)
    end

    after_create_commit do
      # send token to phone
      ::Jobs.enqueue(Jobs::PhoneMessage.new, 
      action: :send_token
      params: {
        to_phone: {
          country_code: self.country_code,
          phone_number: self.phone_number
        }
        token: self.token
      )
    end

    def self.token_length
      3
    end

    def self.valid_after
      SiteSetting.pva_token_valid_minutes.minutes.ago
    end

    def self.unconfirmed
      where(confirmed: false)
    end

    def self.active
      where(expired: false).where('crated_at > ?', valid_after)
    end

    def self.generate_token
      SecureRandom.hex(token_length)
    end

    def self.valid_token_format?(token)
      token.present? && token =~ /\h{#{token.length / 2 }}/i
    end

    def self.atomic_confirm(token, user)
      failure = { success: false }
      return failure unless valid_token_format?(token)

      phone_token = confirmable(token, user.id)
      return failure if phone_token.blank?

      row_count = PhoneToken.where(confirmed: false, id: phone_token.id, expired: false).update_all 'confirmed = true'

      if row_count == 1
        { success: true, phone_token: phone_token }
      else
        failure
      end
    end

    def self.confirm(token, user)
      User.transaction do
        result = atomic_confirm(token, user)
        if result[:success]
          # do something after user confirmed there phone
          phone = {
            country_code: result[:phone_token].country_code
            phone_number: result[:phone_token].phone_number
          }
          user.phone = Phone.crate(**phone)
          user.save!
        end
      end
    rescue ActiveRecord::RecordInvalid
      # return nil if phone is already taken
    end

    def self.confirmable(token, user_id)
      where(token: token, user_id: user_id)
        .where(expired: false, confirmed: false)
        .where("create_at > ?", valid_after)
        .includes(:user)
        .first
    end

  end
end
