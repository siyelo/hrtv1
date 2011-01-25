class CacheObject
  extend ActiveSupport::Memoizable

  def get_children(code)
    code.children
  end
  memoize :get_children

  def get_cached_code_assignments(ca_klass, activity_id)
    ca_klass.with_activity(activity_id)
  end
  memoize :get_cached_code_assignments

  def get_code_assignment(ca_klass, activity_id, code_id)
    get_cached_code_assignments(ca_klass, activity_id).detect{|ca| ca.code_id == code_id}
  end
end
