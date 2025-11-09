class PhoneCall < ApplicationRecord
  enum status: {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed',
    failed: 'failed',
    busy: 'busy',
    no_answer: 'no_answer'
  }

  validates :phone_number, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/ }

  before_create :set_defaults

  def set_defaults
    self.status ||= :pending
    self.attempts ||= 0
  end

  def make_call
    return unless pending?
    
    update(status: :in_progress, attempts: attempts + 1, called_at: Time.current)
    
  
    simulate_call
  end

  private

  def simulate_call
    outcomes = [:completed, :failed, :busy, :no_answer]
    result = outcomes.sample
    
    sleep(2) 
    
    update(
      status: result,
      completed_at: Time.current,
      duration: rand(10..300) 
    )
  end
end