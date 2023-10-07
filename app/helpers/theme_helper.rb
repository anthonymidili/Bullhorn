module ThemeHelper
  def return_active_for_current_theme(theme)
    if theme == cookies[:theme].try(:to_sym) || theme == :system && cookies[:theme].blank?
      "active"
    end
  end
end
