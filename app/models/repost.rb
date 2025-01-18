class Repost < ApplicationRecord
  # Post that reposted.
  belongs_to :post, foreign_key: :post_id,
    class_name: "Post", inverse_of: :repost
  # Reposted post.
  belongs_to :reposted, foreign_key: :reposted_id,
    class_name: "Post", inverse_of: :repost
  belongs_to :user, inverse_of: :reposts
end
