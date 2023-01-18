SELECT id, user_id, body, caption, created_at, type
FROM (
  (
    SELECT id, user_id, body, NULL as caption, created_at, 'Post' as type
    FROM posts
  )
  UNION ALL
  (
    SELECT id, user_id, NULL as body, caption, created_at, 'Photo' as type
    FROM photos
  )
) AS feed_items
ORDER BY created_at DESC;
