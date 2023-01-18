json.extract! job_listing, :id, :title, :type, :status, :comp_min, :comp_max, :comp_per, :description, :apply_email, :show_listing, :user_id, :company_id, :created_at, :updated_at
json.url job_listing_url(job_listing, format: :json)
