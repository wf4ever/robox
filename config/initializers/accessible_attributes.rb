class ActiveRecord::Base
  attr_accessible
  attr_accessor :accessible

  private

  def mass_assignment_authorizer
    if accessible == :all
      self.class.protected_attributes
    else
      super + (accessible || [])
    end
  end
end

ActiveRecord::Base.send :attr_accessible, :session_id

# For Delayed Job:
Delayed::Backend::ActiveRecord::Job.send :attr_accessible,
    :priority,
    :attempts,
    :handler,
    :last_error,
    :run_at,
    :locked_at,
    :failed_at,
    :locked_by,
    :payload_object
