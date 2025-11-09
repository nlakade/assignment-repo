class PhoneCallsController < ApplicationController
  def index
    @phone_calls = PhoneCall.order(created_at: :desc)
    @stats = {
      total: PhoneCall.count,
      completed: PhoneCall.completed.count,
      failed: PhoneCall.failed.count + PhoneCall.busy.count + PhoneCall.no_answer.count,
      pending: PhoneCall.pending.count
    }
  end

  def new
    @phone_call = PhoneCall.new
  end

  def create
    numbers = parse_phone_numbers
    
    numbers.each do |number|
      PhoneCall.create(phone_number: number.strip)
    end
    
    redirect_to phone_calls_path, notice: "#{numbers.size} phone numbers added to queue"
  end

  def start_calling
    pending_calls = PhoneCall.pending.limit(10)
    
    pending_calls.each do |call|
      CallJob.perform_later(call.id)
    end
    
    redirect_to phone_calls_path, notice: "Started calling #{pending_calls.size} numbers"
  end

  def ai_prompt
    prompt = params[:prompt]
    
    if prompt.downcase.include?('call') && prompt.match(/\d{10,}/)
      phone_number = prompt.match(/\d{10,}/)[0]
      phone_call = PhoneCall.create(phone_number: phone_number)
      CallJob.perform_later(phone_call.id)
      
      render json: { message: "Calling #{phone_number}", success: true }
    else
      render json: { message: "Could not extract phone number from prompt", success: false }
    end
  end

  private

  def parse_phone_numbers
    if params[:phone_numbers].present?
      params[:phone_numbers].split(/[\n,]/).reject(&:blank?)
    else
      []
    end
  end
end