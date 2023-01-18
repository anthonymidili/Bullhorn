json.extract! resume, :id, :title, :classification, :status, :is_listed, :created_at, :updated_at
json.url resume_url(resume, format: :json)
