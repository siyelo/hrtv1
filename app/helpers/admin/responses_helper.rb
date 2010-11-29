module Admin::ResponsesHelper
  def active_if(action_name)
    active = false
    current = controller.action_name.to_sym
    if action_name.is_a?(Array)
      active = true if action_name.include?(current)
    else
      active = true if action_name == current
    end
    { :class => ('active' if active) }
  end
end
