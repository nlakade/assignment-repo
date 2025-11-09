class CallJob < ApplicationJob
  queue_as :default

  def perform(phone_call_id)
    phone_call = PhoneCall.find(phone_call_id)
    phone_call.make_call
  end
end