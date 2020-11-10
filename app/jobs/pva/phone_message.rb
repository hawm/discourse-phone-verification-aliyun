module HAWM::PVA::Jobs
  class PhoneMessage < ::Jobs::Base
    MAX_RETRY_COUNT = 3

    sidekiq_options queue: 'critical'

    def execute(args)
      @arguments = args
      @retry_count = args[:retry_count] || 0

      @sms_action = args[:action]
      @sms_params = args[:params]

      # TODO: implement dynamic dispatch provider
      @sms = HAWM::SMSProvider::AliyunSMS.new

      send!
    end

    def retry
      @retry_count += 1
      return if @retry_count > MAX_RETRY_COUNT
      @arguments[:retry_count] = @retry_count
      # retry delay 5 seconds
      ::Jobs.enqueue(5, PhoneMessage.new, @arguments)
    end
  end
end
