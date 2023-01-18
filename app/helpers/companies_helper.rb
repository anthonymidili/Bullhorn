module CompaniesHelper
  def current_company
    @current_company ||=
      if user_signed_in?
        set_current_company_cookie if params[:company_id]
        current_user.companies.find_by(id: session[:current_company_id])
      end
  end

private

  def set_current_company_cookie
    session[:current_company_id] = params[:company_id]
  end
end
