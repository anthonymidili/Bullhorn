module ApplicationHelper

  #Returns the full title on a per-paage basis.
  def full_title(page_title)
    app_name = 'Bullhorn'
    page_title.empty? ? app_name : "#{app_name} | #{page_title}"
  end
end

