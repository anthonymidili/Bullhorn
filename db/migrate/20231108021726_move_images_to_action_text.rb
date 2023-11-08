class MoveImagesToActionText < ActiveRecord::Migration[7.0]
  include ActionText::Attachable
  def change
    Post.all.each do |post|
      images = ActiveStorage::Attachment.where(record_type: 'Post', record_id: post.id)
      if images.any?
        htmls = %Q("#{post.body.to_plain_text}")
        images.each do |image|
          attachable = image.blob
          htmls << %Q(<action-text-attachment sgid="#{attachable.attachable_sgid}" caption=""></action-text-attachment>)
        end
        post.update_attribute(:body, htmls)
        post.images.purge
      end
    end
  end
end
