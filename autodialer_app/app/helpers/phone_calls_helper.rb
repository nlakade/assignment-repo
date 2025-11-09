module PhoneCallsHelper
  def status_badge_color(status)
    case status
    when 'completed'
      'success'
    when 'failed', 'busy', 'no_answer'
      'danger'
    when 'in_progress'
      'warning'
    else
      'secondary'
    end
  end
end