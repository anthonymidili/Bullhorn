json.extract! bug_report, :id, :subject, :body, :user_id, :name, :email, :created_at, :updated_at
json.url bug_report_url(bug_report, format: :json)
