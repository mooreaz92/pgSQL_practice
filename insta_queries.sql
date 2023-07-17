-- Very basic practice queries --

-- Query that finds the three highest user ID's

SELECT user_id
FROM users
ORDER BY user_id DESC
LIMIT 3;

-- Query that returns username and caption for particular user ID

SELECT username, caption
FROM users
JOIN posts ON posts.user_id = users.ID
WHERE users.id = 200;

-- Query that shows number of created likes per user

SELECT username, COUNT(*)
FROM users
JOIN likes ON likes.user_id = users.id
GROUP BY username;

-- Indexing to improve performance on username --

-- Creating index on username column

CREATE INDEX users_username_idx ON users (username);

-- Benchmarking query with and without index

EXPLAIN ANALYZE SELECT *
FROM users
WHERE username = 'Emil30';

-- Practicing with CTEs (local and recursive) --

-- Creating a tags CTE and querying for total tags per username

WITH tags AS (
    SELECT user_id, created_at FROM caption_tags
    UNION ALL
    SELECT user_id, created_at FROM photo_tags
)

SELECT username, COUNT(tags.created_at)
FROM users
JOIN tags ON tags.user_id = users.id
GROUP BY username
ORDER BY tags.created_at DESC;

-- Creating a recursive CTE to make a suggestions table for users to follow

WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
        SELECT leader_id, follower_id, 1 AS depth
        FROM followers
        WHERE follower_id = 1000
    UNION
        SELECT followers.leader_id, followers.follower_id, depth + 1
        FROM followers
        JOIN suggestions ON suggestions.leader_id = followers.follower_id
        WHERE depth < 3
)
SELECT DISTINCT users.id, users.username
FROM suggestions
JOIN users ON users.id = suggestions.leader_id
WHERE depth > 1
LIMIT 30;

-- Practicing with views (simple and materialized) --

 -- Creating a simple view for total number of tags per user

CREATE VIEW tags_per_user AS
    SELECT id, created_at, user_id, post_id, 'photo_tag' AS type FROM photo_tags
    UNION ALL
    SELECT id, created_at, user_id, post_id, 'caption_tag' AS type FROM caption_tags;

SELECT *
FROM tags_per_user
WHERE type = 'photo_tag';

-- Creating a materialized view for total number of tags per week

CREATE MATERIALIZED VIEW weekly_likes AS (
    SELECT
        date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
        COUNT(posts.id) AS num_likes_for_posts,
        COUNT(comments.id) AS num_likes_for_comments
    FROM likes
    LEFT JOIN posts ON posts.id = likes.post_id
    LEFT JOIN comments ON comments.id = likes.comment_id
    GROUP BY week
    ORDER BY week
) WITH DATA;

-- Practicing with transactions in a new table

BEGIN;

UPDATE accounts
SET balance = balance - 50
WHERE name = 'Alyson';

UPDATE accounts
SET balance = balance + 50
WHERE name = 'Brett';

COMMIT;









