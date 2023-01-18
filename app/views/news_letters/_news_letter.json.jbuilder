json.extract! news_letter, :id, :issue_number, :issued_on, :created_at, :updated_at
json.url news_letter_url(news_letter, format: :json)
