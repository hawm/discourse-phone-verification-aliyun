class UsersPhoneConstraint
  def matches?(request)
    SiteSetting.phone_verification_aliyun_enabled &&
    request.path_parameters[:username].match?(RouteFormat.username)
  end
end
