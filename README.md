# Social Sphere
## Overview 
This project models a simplified social media platform with core features such as user registration, posting, liking, commenting, following, direct messaging, and notifications. The schema includes the following main tables:

 •users: Stores account information and profile details.

 •posts: Contains user-generated content (text, images, videos).

 •comments, likes: Support user engagement.

 •follows: Represents follower-following relationships.

 •messages: Enables direct messaging between users.

 •notifications: Alerts users about interactions.

 •hashtags and post_hashtags: Enable hashtag tagging and trend tracking.


Each table has been populated with sample data to support realistic analysis and reporting.
## Objectives 
To design and implement a social media analytics database system that enables data-driven decision-making by tracking user engagement, content performance, and network interactions, helping businesses optimize their social media strategies and maximize audience reach.
## Creating Database
``` sql
CREATE DATABASE SSA_db;
USE SSA_db;
```
## Creating Table
### Table:users
``` sql
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
```
### Table:posts
``` sql
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
```
### Table:comments
``` sql
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
```
### Table:likes
``` sql
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
```
### Table:follows
``` sql
CREATE TABLE follows(
    follow_id    INT PRIMARY KEY AUTO_INCREMENT,
    follower_id  INT,
    following_id INT,
    created_at   DATETIME
);

SELECT * FROM follows ;
```
### Table:messages
 sql
CREATE TABLE messages(
    message_id    INT PRIMARY KEY AUTO_INCREMENT,
    sender_id     INT,
    receiver_id   INT,
    content       TEXT,
    sent_at       DATETIME,
    is_read       BOOLEAN
);

SELECT * FROM messages ;
```
### Table:notifications
``` sql
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
```
### Table:hashtags
``` sql
CREATE TABLE hashtags(
    hashtag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag        TEXT,
    created_at DATETIME
);

SELECT * FROM hashtags ;
```
### Table:post_hashtags
``` sql
CREATE TABLE post_hashtags(
    post_hashtag_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id         INT,
    hashtag_id      INT,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id)
);

SELECT * FROM post_hashtags ;
```
## Key Queries 

#### 1. Who are the top 5 most active users based on their post count?
``` sql
SELECT 
        u.username,COUNT(p.post_id) AS Total_posts
FROM users u 
JOIN posts p ON p.user_id=u.user_id
WHERE LOWER(u.account_status)='active'
GROUP BY u.username
ORDER BY Total_posts DESC 
LIMIT 5;
```
#### 2. How many new users have joined in the last 30 days, broken down by day?
``` sql
SELECT 
        date_joined,COUNT(*) AS New_users 
FROM users 
WHERE date_joined>=DATE_SUB(CURDATE(),INTERVAL 30 DAY)
GROUP BY date_joined;
```
#### 3. Which posts have received the most likes, and who created them?
``` sql
SELECT 
        p.content, u.username,COUNT(l.like_id) AS Total_likes
FROM users u 
JOIN posts p ON p.user_id=u.user_id
JOIN likes l ON l.post_id=p.post_id
GROUP BY p.content,u.username
ORDER BY Total_likes DESC;
```
#### 4. Which posts have generated the most comments, and who created them?
``` sql
SELECT 
        p.content, u.username,COUNT(c.comment_id) AS Total_Comments
FROM users u 
JOIN posts p ON p.user_id=u.user_id
JOIN comments c ON c.post_id=p.post_id
GROUP BY p.content,u.username
ORDER BY Total_Comments DESC;
```
#### 5. Who are the top 5 most followed users on the platform?
``` sql
SELECT 
        u.username,COUNT(f.follow_id) AS Total_followers
FROM users u 
JOIN follows f ON u.user_id=f.following_id
GROUP BY u.username
ORDER BY Total_followers DESC
LIMIT 5;
```
#### 6. Which pairs of users follow each other mutually (reciprocal follows)?
``` sql
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
```
#### 7. What are the peak hours when users are most active in posting content?
``` sql
SELECT 
    HOUR(created_at) AS post_hour,
    COUNT(*) AS total_posts
FROM posts
WHERE created_at IS NOT NULL
GROUP BY HOUR(created_at)
ORDER BY total_posts DESC;
```
#### 8. What percentage of users engage by posting, commenting, or liking content?
``` sql
SELECT 
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(DISTINCT user_id) FROM posts) AS posting_users,
    (SELECT COUNT(DISTINCT user_id) FROM comments) AS commenting_users,
    (SELECT COUNT(DISTINCT user_id) FROM likes) AS liking_users;
```
#### 9. What are the top 10 most frequently used hashtags across all posts?
``` sql
 SELECT 
        h.tag AS Hashtag,COUNT(ph.post_hashtag_id) AS Usage_count
FROM hashtags h 
JOIN post_hashtags ph ON ph.hashtag_id=h.hashtag_id
GROUP BY Hashtag
ORDER BY Usage_count DESC 
LIMIT 10;
```
#### 10. What is the average number of likes and comments per post?
``` sql
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
```
#### 11. Which user pairs exchange the most direct messages?
``` sql
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
```
#### 12. How many unread notifications exist, categorized by notification type?
``` sql
SELECT 
        type,COUNT(*) AS Total_notifications
FROM notifications
WHERE is_read=FALSE
GROUP BY type;
```
#### 13. Which users are active (logged in recently) but have never made a post?
``` sql
SELECT 
    u.username,u.full_name,u.last_login
FROM users u
WHERE 
    u.last_login >= NOW() - INTERVAL 30 DAY
    AND u.user_id NOT IN (SELECT DISTINCT user_id FROM posts);
```
## Conclusion
This relational database provides a foundational structure for analyzing user activity and engagement in a social platform. The provided analytical queries help extract key insights such as:

 •Most active and followed users.

 •Peak engagement hours.

 •Popular hashtags.

 •User interaction patterns (likes, comments, messages).
 
 •Engagement metrics and behavior of active vs inactive users.

