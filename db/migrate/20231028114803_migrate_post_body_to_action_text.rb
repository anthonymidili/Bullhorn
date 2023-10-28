class MigratePostBodyToActionText < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper
  def change
    rename_column :posts, :body, :old_body
    Post.all.each do |post|
      post.update_attribute(:body, simple_format(post.old_body))
    end
    remove_column :posts, :old_body
  end
end
