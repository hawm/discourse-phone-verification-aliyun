require_dependency "users_phone_constraint"

HAWM::PVA::Engine.routes.draw do
  get "/u/:username/preferences/phone" => "users_phone#index", constraints: UsersPhoneConstraint.new
  post "/u/:username/preferences/phone" => "users_phone#create", constraints: UsersPhoneConstraint.new
  put "/u/:username/preferences/phone" => "users_phone#update", constraints: UsersPhoneConstraint.new
  delete "/u/:username/preferences/phone" => "users_phone#destory", constraints: UsersPhoneConstraint.new
  post "/u/:username/preferences/phone-detail" => "users_phone#show", constraints: UsersPhoneConstraint.new
end
