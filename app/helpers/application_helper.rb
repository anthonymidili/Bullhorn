module ApplicationHelper
  def safe_return_path
    return_to = cookies[:return_to]
    return root_path if return_to.blank?
    return root_path unless return_to.start_with?("/")
    return_to
  end
end
