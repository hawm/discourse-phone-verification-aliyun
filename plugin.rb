# frozen_string_literal: true

# name: phone-verification-aliyun
# about: Verify user's phone number via Aliyun SMS
# version: 0.1
# authors: hawm
# url: https://github.com/hawm

register_svg_icon "mobile"
register_svg_icon "sms"

enabled_site_setting :hawm_pva_enable

PLUGIN_NAME ||= 'HAWM::PVA'

#require_dependency File.expand_path('lib/pva/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb

end
