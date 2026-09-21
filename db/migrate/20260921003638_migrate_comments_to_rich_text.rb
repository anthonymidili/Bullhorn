class MigrateCommentsToRichText < ActiveRecord::Migration[8.1]
  def up
    # Migrate any existing text bodies to ActionText::RichText
    Comment.reset_column_information
    Comment.find_each do |comment|
      text_body = comment.read_attribute(:body)
      if text_body.present?
        ActionText::RichText.find_or_create_by!(
          record_type: "Comment",
          record_id: comment.id,
          name: "body"
        ) do |rt|
          rt.body = text_body
        end
      end
    end

    remove_column :comments, :body, :text
  end

  def down
    add_column :comments, :body, :text
    Comment.reset_column_information
    Comment.find_each do |comment|
      rt = ActionText::RichText.find_by(record_type: "Comment", record_id: comment.id, name: "body")
      if rt&.body.present?
        comment.update_column(:body, rt.body.to_plain_text)
      end
    end
  end
end
