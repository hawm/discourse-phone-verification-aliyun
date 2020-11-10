require 'rails_helper'

describe phone-verification-aliyun::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/phone-verification-aliyun/list.json"
    expect(response.status).to eq(200)
  end
end
