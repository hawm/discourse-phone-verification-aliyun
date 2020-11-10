class ::User
  has_one :phone, class_name: "HAWM::PVA::Phone", dependent: :delete
  has_many :phone_token, class_name: "HAWM::PVA::PhoneToken", dependent: :delete_all
end
