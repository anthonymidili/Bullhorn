module ApplicationHelper
  def safe_return_path
    return_to = cookies[:return_to]
    return root_path if return_to.blank?
    return root_path unless return_to.start_with?("/")
    return_to
  end

  def body_data_attributes
    return {} unless user_signed_in?

    {
      controller: "page-visibility",
      page_visibility_user_id_value: current_user.id
    }
  end
end
