module DashboardHelper

  def class_name_for_sync_status(status)
    case status
      when :pending
        'notice'
      when :running
        'notice'
      when :failed
        'error'
      when :success
        'success'
      else
        ''
    end
  end

end