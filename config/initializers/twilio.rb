require 'rubygems'
require 'twilio-ruby'

module TwilioSms
  # TwilioSms.send_text("+91*******", "Hello")
  def self.send_text(phone, content)
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']

    twilio_phone_number = "+19136677040"
    begin
      pp "printing #{twilio_sid}  , #{twilio_token}"
      @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
      pp "printing2 #{@twilio_client}"
      @twilio_client.api.account.messages.create(
        :from => twilio_phone_number,
        :to => phone,
        :body=> content
      )
      pp "printing3 successfully sent"

      return "send"
    rescue  Twilio::REST::RestError => e
      Rails.logger.info("#{e} --- #{e.message}")
      return e.message
    end

  end
end
