CREATE DATABASE SSA_db;
USE SSA_db;

CREATE TABLE users(
    user_id        INT PRIMARY KEY AUTO_INCREMENT,
    username       TEXT,
    email          TEXT,
    password_hash  TEXT,
    full_name      TEXT,
    bio            TEXT,
    date_joined    DATE,
    last_login     DATETIME,
    is_verified    BOOLEAN,
    account_status VARCHAR(50)
);

SELECT * FROM users ;

INSERT INTO users(username,email,password_hash,full_name,bio,is_verified)  VALUES
	('john_doe', 'john@example.com', '$2y$10$EXAMPLEHASH', 'John Doe', 'Digital creator | Photography enthusiast', TRUE),
	('sarah_smith', 'sarah@example.com', '$2y$10$EXAMPLEHASH', 'Sarah Smith', 'Travel blogger | Foodie', FALSE),
	('mike_jones', 'mike@example.com', '$2y$10$EXAMPLEHASH', 'Mike Jones', 'Tech geek | Gadget reviewer', TRUE),
	('emily_wilson', 'emily@example.com', '$2y$10$EXAMPLEHASH', 'Emily Wilson', 'Fitness coach | Nutritionist', FALSE),
	('david_brown', 'david@example.com', '$2y$10$EXAMPLEHASH', 'David Brown', 'Music producer | DJ', TRUE);

CREATE TABLE posts(
    post_id         INT PRIMARY KEY AUTO_INCREMENT,
    user_id         INT,
    content         TEXT,
    image_url       TEXT,
    video_url       TEXT,
    created_at      DATETIME,
    updated_at      DATETIME,
    privacy_setting VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT * FROM posts ;

INSERT INTO posts(user_id,content,privacy_setting)  VALUES
	(1, 'Beautiful sunset at the beach today! #sunset #vacation', 'public'),
	(2, 'Just tried this amazing new restaurant in town! #foodie #dining',  'public'),
	(3, 'Review of the new smartphone - definitely worth the upgrade! #tech #gadgets', 'public'),
	(4, 'Morning workout routine complete! #fitness #health', 'friends'),
	(5, 'New track dropping next week! Stay tuned #music #producer', 'public');

CREATE TABLE comments(
    comment_id        INT PRIMARY KEY AUTO_INCREMENT,
    post_id           INT,
    user_id           INT,
    content           TEXT,
    created_at        DATETIME,
    parent_comment_id INT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT * FROM comments ;

INSERT INTO comments(post_id,user_id,content)  VALUES
	(1, 2, 'Wow, that looks amazing! Where was this taken?'),
	(1, 3, 'Great shot! The colors are incredible.'),
	(2, 1, 'What restaurant is this? I need to try it!'),
	(3, 5, 'I agree, the camera is a huge improvement.'),
	(4, 2, 'Inspiring! What time do you usually workout?');

CREATE TABLE likes(
    like_id       INT PRIMARY KEY AUTO_INCREMENT,
    post_id       INT,
    comment_id    INT,
    user_id       INT,
    created_at    DATETIME,
    reaction_type VARCHAR(50),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (comment_id) REFERENCES comments(comment_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT * FROM likes ;

INSERT INTO likes(post_id,user_id,reaction_type)  VALUES
	(1, 2, 'love'),
	(1, 3, 'like'),
	(1, 4, 'wow'),
	(2, 1, 'like'),
	(3, 5, 'like'),
	(4, 2, 'like'),
	(5, 1, 'love'),
	(5, 3, 'like');

CREATE TABLE follows(
    follow_id    INT PRIMARY KEY AUTO_INCREMENT,
    follower_id  INT,
    following_id INT,
    created_at   DATETIME
);

SELECT * FROM follows ;

INSERT INTO follows(follower_id,following_id)  VALUES
	(2, 1),
	(3, 1),
	(4, 1),
	(1, 2),
	(3, 2),
	(1, 5),
	(2, 5);

CREATE TABLE messages(
    message_id    INT PRIMARY KEY AUTO_INCREMENT,
    sender_id     INT,
    receiver_id   INT,
    content       TEXT,
    sent_at       DATETIME,
    is_read       BOOLEAN
);

SELECT * FROM messages ;

INSERT INTO  messages(sender_id,receiver_id,content) VALUES
	(1, 2, 'Hey Sarah, thanks for the comment on my post!'),
	(2, 1, 'No problem John, it was a great photo!'),
	(3, 1, 'Do you have the original high-res version of that sunset pic?'),
	(1, 5, 'Hey David, would love to collaborate on something!'),
	(5, 1, 'Sounds interesting, let me know what you have in mind.');

CREATE TABLE notifications(
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id         INT,
    source_id       INT,
    type            VARCHAR(50),
    content         TEXT,
    is_read         BOOLEAN,
    created_at      DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT * FROM notifications ;

INSERT INTO  notifications(user_id,source_id,type,content) VALUES
	(1, 2, 'like', 'Sarah Smith liked your post'),
	(1, 2, 'comment', 'Sarah Smith commented on your post'),
	(1, 3, 'follow', 'Mike Jones started following you'),
	(2, 1, 'comment', 'John Doe replied to your comment'),
	(5, 1, 'message', 'You received a message from John Doe');

CREATE TABLE hashtags(
    hashtag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag        TEXT,
    created_at DATETIME
);

SELECT * FROM hashtags ;

INSERT INTO hashtags(tag) VALUES
	('#sunset'),
	('#vacation'),
	('#foodie'),
	('#dining'),
	('#tech'),
	('#gadgets'),
	('#fitness'),
	('#health'),
	('#music'),
	('#producer');

CREATE TABLE post_hashtags(
    post_hashtag_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id         INT,
    hashtag_id      INT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id)
);

SELECT * FROM post_hashtags ;

INSERT INTO  post_hashtags(post_id,hashtag_id) VALUES
	(1, 1),
	(1, 2),
	(2, 3),
	(2, 4),
	(3, 5),
	(3, 6),
	(4, 7),
	(4, 8),
	(5, 9),
	(5, 10);

SELECT 
	u.username,COUNT(p.post_id) AS Total_posts
FROM users u 
JOIN posts p ON p.user_id=u.user_id
WHERE LOWER(u.account_status)='active'
GROUP BY u.username
ORDER BY Total_posts DESC 
LIMIT 5;

SELECT 
	date_joined,COUNT(*) AS New_users 
FROM users 
WHERE date_joined>=DATE_SUB(CURDATE(),INTERVAL 30 DAY)
GROUP BY date_joined;

SELECT 
	p.content, u.username,COUNT(l.like_id) AS Total_likes
FROM users u 
JOIN posts p ON p.user_id=u.user_id
JOIN likes l ON l.post_id=p.post_id
GROUP BY p.content,u.username
ORDER BY Total_likes DESC;

SELECT 
	p.content, u.username,COUNT(c.comment_id) AS Total_Comments
FROM users u 
JOIN posts p ON p.user_id=u.user_id
JOIN comments c ON c.post_id=p.post_id
GROUP BY p.content,u.username
ORDER BY Total_Comments DESC;

SELECT 
	u.username,COUNT(f.follow_id) AS Total_followers
FROM users u 
JOIN follows f ON u.user_id=f.following_id
GROUP BY u.username
ORDER BY Total_followers DESC
LIMIT 5;

SELECT 
    u1.username AS user_a,
    u2.username AS user_b
FROM follows f1
JOIN follows f2 ON 
	f1.follower_id = f2.following_id 
    AND f1.following_id = f2.follower_id
JOIN users u1 ON f1.follower_id = u1.user_id
JOIN users u2 ON f1.following_id = u2.user_id
WHERE f1.follower_id < f1.following_id;

SELECT 
    HOUR(created_at) AS post_hour,
    COUNT(*) AS total_posts
FROM posts
WHERE created_at IS NOT NULL
GROUP BY HOUR(created_at)
ORDER BY total_posts DESC;
    
SELECT 
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(DISTINCT user_id) FROM posts) AS posting_users,
    (SELECT COUNT(DISTINCT user_id) FROM comments) AS commenting_users,
    (SELECT COUNT(DISTINCT user_id) FROM likes) AS liking_users;

 SELECT 
	h.tag AS Hashtag,COUNT(ph.post_hashtag_id) AS Usage_count
FROM hashtags h 
JOIN post_hashtags ph ON ph.hashtag_id=h.hashtag_id
GROUP BY Hashtag
ORDER BY Usage_count DESC 
LIMIT 10;

SELECT
    ROUND(AVG(like_count), 2) AS avg_likes_per_post,
    ROUND(AVG(comment_count), 2) AS avg_comments_per_post
FROM (
    SELECT 
        p.post_id,
        COUNT(DISTINCT l.like_id) AS like_count,
        COUNT(DISTINCT c.comment_id) AS comment_count
    FROM posts p
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY p.post_id
) AS post_stats;

SELECT 
    u1.username AS user1,
    u2.username AS user2,
    msg_count.total_messages
FROM (
    SELECT 
        LEAST(sender_id, receiver_id) AS user1_id,
        GREATEST(sender_id, receiver_id) AS user2_id,
        COUNT(*) AS total_messages
    FROM messages
    GROUP BY LEAST(sender_id, receiver_id), GREATEST(sender_id, receiver_id)
) AS msg_count
JOIN users u1 ON msg_count.user1_id = u1.user_id
JOIN users u2 ON msg_count.user2_id = u2.user_id
ORDER BY msg_count.total_messages DESC;

SELECT 
	type,COUNT(*) AS Total_notifications
FROM notifications
WHERE is_read=FALSE
GROUP BY type;

SELECT 
    u.username,u.full_name,u.last_login
FROM users u
WHERE 
    u.last_login >= NOW() - INTERVAL 30 DAY
    AND u.user_id NOT IN (SELECT DISTINCT user_id FROM posts);