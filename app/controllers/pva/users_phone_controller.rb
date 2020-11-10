module HAWM::PVA
  class UsersPhoneController < ::ApplicationController
    requires_plugin PVA

    before_action :ensure_logged_in
    before_action :ensure_admin, only: [:destory]

    def index
    end

    def show
      unless params[:password].empty?
        RateLimiter.new(nil, "login-hr-#{request.remote_ip}", SiteSetting.max_logins_per_ip_per_hour, 1.hour).performed!
        RateLimiter.new(nil, "login-min-#{request.remote_ip}", SiteSetting.max_logins_per_ip_per_minute, 1.minute).performed!
        unless current_user.confirm_password?(params[:password])
          return render json: failed_json.merge(
            error: I18n.t("login.incorrect_password")
          )
        end
        confirm_secure_session
      else
        user = fetch_user_from_params
      end

      if secure_session_confirmed?
        #phone = current_user&.phone.mask
        phone = {
          prefix: "+86",
          number: "********8000"
        }
        render json: success_json.merge(
          phone: phone,
        )
      elsif guardian.is_admin? && defined?(user) && !user&.admin?
        # allow admin check others
        # phone = user&.phone&.unmask
        phone = {
          prefix: "+86",
          number: "13800138000"
        }
        render json: success_json.merge(
          phone: phone,
        )
      else
        render json: success_json.merge(
            password_required: true
        )
      end
    end

    def create
      params.require(:phone)
      user = fetch_user_from_params

      RateLimiter.new(user, "phone-hr-#{request.remote_ip}", 10, 1.hour).preformed!
      RateLimiter.new(user, "phone-min-#{request.remote_ip}", 2, 1.minute).preformed!

    end

    def update
    end

    private

    def confirm_secure_session
      secure_session["confirmed-password-#{current_user.id}"] = "true"
    end

    def secure_session_confirmed?
      secure_session["confirmed-password-#{current_user.id}"] == "true"
    end

  end
end
