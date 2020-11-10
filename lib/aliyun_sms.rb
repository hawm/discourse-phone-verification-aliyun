require 'uri'
require 'openssl'
require 'base64'
require 'time'
require 'securerandom'
require 'excon'
require 'json'
require 'excon'

# https://help.aliyun.com/document_detail/101414.html
# https://help.aliyun.com/document_detail/101343.html
# https://vallen1982.gitbooks.io/pop-docs/content/

module HAWM::SMSProvider
    class AliyunSMS
      SIGNATURE_METHOD = "HMAC-SHA1"
      SIGNATURE_VERSION = "1.0"
      VERSION = "2017-05-25"

      def self.common_params
        {
            version: VERSION,
            signature_method: SIGNATURE_METHOD,
            signature_version: SIGNATURE_VERSION,
            signature_nonce: SecureRandom.uuid,
            timestamp: Time.now.utc.iso8601,
            format: "JSON"
        }
      end

      def self.pop_special_encode(str)
        str.gsub(/\+|\*|\%7E/, { "+": "%20", "*": "%2A", "%7E": "~" })
      end

      def self.sign(secret, data)
        Base64.strict_encode64(OpenSSL::HMAC.digest("SHA1", secret + "&", data))
      end

      def self.build_uri(access_key_secret, endpoint, http_method, params)
        canonicalized_query_string = pop_special_encode(
          URI.encode_www_form(
            params.merge(common_params).transform_keys { |k| k.to_s.camelize }.sort_by { | k, v | k }
            )
          )
        to_sign_string = [http_method.to_s.upcase, "%2F", URI.encode_www_form_component(canonicalized_query_string)].join("&")
        signature = sign(access_key_secret, to_sign_string)
        URI::HTTPS.build(host: endpoint, path: "/", query: "Signature=" + signature + "&" + canonicalized_query_string)
      end

      def self.load_config_from_site_setting
        config = {}
          SiteSetting.settings_hash.each  do | k, v |
            # using Hash filter_map when Ruby 2.7+
            k.match /pva_aliyun_sms_(.+)/ do | m |
              if (name = m&.[](1))
                config[name] = v
              else
                # TODO
              end
            end
          end

        config
      end


      def initialize(config: nil)
        @config = config || AliyunSMS.load_config_from_site_setting
      end

      def send_token(to_phone, token)
        param_exclude_keys = ["access_key_secret", "send_endpoint", "http_method", "template_parameter_name"]
        uri = AliyunSMS.build_uri(
              *@config.fetch_values(*param_exclude_keys[0...-1]),
              @config.except(*param_exclude_keys).merge({
                      phone_numbers: to_phone,
                      template_param: {
                          @config["template_parameter_name"] => token
                      }.to_json,
                      action: "SendSms"
              })
          )

          # TODO
      end

end
