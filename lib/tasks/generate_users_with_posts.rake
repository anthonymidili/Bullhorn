## Default: 10 users with 5 posts each
# rake generate:users_with_posts

## Custom: 20 users with 10 posts each
# rake generate:users_with_posts USERS=20 POSTS=10

namespace :generate do
  desc "Generate users with posts"
  task users_with_posts: :environment do
    num_users = ENV["USERS"]&.to_i || 10
    posts_per_user = ENV["POSTS"]&.to_i || 5

    puts "Generating #{num_users} users with #{posts_per_user} posts each..."

    # Clean up existing test users (optional, comment out to keep previous data)
    puts "Cleaning up existing test users..."
    User.where("username LIKE ?", "user%").find_each do |user|
      user.posts.destroy_all
      user.destroy
    end

    users = []

    num_users.times do |i|
      user = User.create!(
        email: "user#{i + 1}@example.com",
        username: "user#{i + 1}",
        password: "password123",
        password_confirmation: "password123",
        confirmed_at: Time.current
      )

      users << user
      puts "Created user: #{user.username}"

      # Create posts for this user
      posts_per_user.times do |j|
        body_content = "This is post #{j + 1} from #{user.username}. " \
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

        post = user.posts.create!(
          body: body_content
        )
        puts "  └─ Created post: #{post.id}"
      end
    end

    # Create some follows relationships for more realistic data
    puts "\nGenerating follow relationships..."
    users.each do |user|
      # Each user follows 2-5 random other users
      follow_count = rand(2..5)
      other_users = users - [ user ]
      random_users = other_users.sample(follow_count)

      random_users.each do |followed_user|
        Relationship.create!(user_id: user.id, followed_id: followed_user.id)
      end

      puts "#{user.username} is now following #{follow_count} users"
    end

    puts "\n✓ Successfully generated #{num_users} users with #{posts_per_user} posts each!"
    puts "Usage: rake generate:users_with_posts USERS=20 POSTS=10"
  end
end
