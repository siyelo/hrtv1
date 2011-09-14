module ResponseStatesHelper
  def state_to_name(state)
    case state
    when 'unstarted' : 'Not Yet Started'
    when 'started'   : 'Started'
    when 'submitted' : 'Submitted'
    when 'rejected'  : 'Rejected'
    when 'accepted'  : 'Accepted'
    end
  end

  def name_to_state(filter)
    case filter
    when 'Not Yet Started' : 'unstarted'
    when 'Started'         : 'started'
    when 'Submitted'       : 'submitted'
    when 'Rejected'        : 'rejected'
    when 'Accepted'        : 'accepted'
    end
  end
end
