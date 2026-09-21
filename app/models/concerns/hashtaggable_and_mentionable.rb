module HashtaggableAndMentionable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :hashtags, through: :taggings

    after_save :sync_hashtags
  end

  def extract_hashtag_names
    content_text = extract_plain_text
    return [] if content_text.blank?

    content_text.scan(/(?<=^|[^\w#])#([a-zA-Z0-9_]+)\b/).flatten.map(&:downcase).uniq
  end

  def extract_mentioned_usernames
    content_text = extract_plain_text
    return [] if content_text.blank?

    content_text.scan(/(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/).flatten.map(&:downcase).uniq
  end

  def mentioned_users
    usernames = extract_mentioned_usernames
    return User.none if usernames.empty?

    User.where(username: usernames)
  end

  def sync_hashtags
    names = extract_hashtag_names
    current_names = hashtags.pluck(:name).map(&:downcase)

    return if names.sort == current_names.sort

    new_hashtags = names.map do |name|
      Hashtag.find_or_create_by(name: name)
    end
    self.hashtags = new_hashtags
  end

  private

  def extract_plain_text
    if respond_to?(:body) && body.present?
      if body.respond_to?(:to_plain_text)
        body.to_plain_text
      else
        body.to_s
      end
    else
      ""
    end
  end
end
