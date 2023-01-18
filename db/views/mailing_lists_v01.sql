SELECT first_name, last_name, email, created_at, updated_at
FROM (
  (
    SELECT first_name, last_name, email, created_at, updated_at
    FROM users
  )
  UNION ALL
  (
    SELECT first_name, last_name, email, created_at, updated_at
    FROM additional_recipients
  )
) AS mailing_lists
