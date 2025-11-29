require "test_helper"

class NewActivityMailerTest < ActionMailer::TestCase
  test "new_activity sets recipient, subject, and attachment" do
    to = User.create!(email: "mail_to@example.com", password: "password", username: "mailto", confirmed_at: Time.current)
    from = User.create!(email: "mail_from@example.com", password: "password", username: "mailfrom", confirmed_at: Time.current)
    post = from.posts.create!(body: "Mailer test post")

    # Ensure the attachment file exists for the mailer
    attachments_dir = File.join(Rails.root, "app", "assets", "images")
    FileUtils.mkdir_p(attachments_dir) unless Dir.exist?(attachments_dir)
    file_path = File.join(attachments_dir, "bullhorn.png")
    begin
      File.write(file_path, "png-data") unless File.exist?(file_path)

      mail = NewActivityMailer.new_activity(to, from, post, "added a post")

      assert_equal [ to.email ], mail.to
      assert_includes mail.subject, from.username
      # attachments is a Mail::Field; check there is at least one attachment
      assert mail.has_attachments?
    ensure
      # leave the file in place; no cleanup to avoid affecting asset pipeline
    end
  end
end
