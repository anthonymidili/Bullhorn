module PostsHelper
  def post_reposting_id(record, reposting = nil)
    prefix = record.class.name.underscore
    if reposting
      "#{prefix}_#{record.id}_reposting_#{reposting.id}"
    else
      "#{prefix}_#{record.id}"
    end
  end
end
