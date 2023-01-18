class NewsLetter < ApplicationRecord
  has_many :articles, dependent: :destroy

  validates :issue_number, numericality: true, uniqueness: true
  validates :issued_on, presence: true

  default_scope { order(issue_number: :desc) }

  scope :by_published, -> { where(published: true) }

  # Getter to set issue_number on form or create
  def issue_number
    self[:issue_number] ||= (NewsLetter.maximum(:issue_number).to_i).succ
  end

  # Getter to set issued_on on form or create
  def issued_on
    self[:issued_on] ||= Date.current
  end

  def articles_titles
    articles.map(&:title).join(', ')
  end

  def mail_recipients
    NewsLetterWorker.perform_async(self.id)
  end
end
