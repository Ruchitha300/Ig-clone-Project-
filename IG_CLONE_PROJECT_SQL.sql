CREATE DATABASE ig_clone;

USE ig_clone;

CREATE TABLE users(
	id INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
	username VARCHAR(255) NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE photos(
	id INT AUTO_INCREMENT PRIMARY KEY,
	image_url VARCHAR(355) NOT NULL,
	user_id INT NOT NULL,
	created_dat TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE comments(
	id INT AUTO_INCREMENT PRIMARY KEY,
	comment_text VARCHAR(255) NOT NULL,
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);

CREATE TABLE likes(
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	PRIMARY KEY(user_id,photo_id)
);

CREATE TABLE follows(
	follower_id INT NOT NULL,
	followee_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY (follower_id) REFERENCES users(id),
	FOREIGN KEY (followee_id) REFERENCES users(id),
	PRIMARY KEY(follower_id,followee_id)
);

CREATE TABLE tags(
	id INTEGER AUTO_INCREMENT PRIMARY KEY,
	tag_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE photo_tags(
	photo_id INT NOT NULL,
	tag_id INT NOT NULL,
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	FOREIGN KEY(tag_id) REFERENCES tags(id),
	PRIMARY KEY(photo_id,tag_id)
);

use ig_clone;
select * from users;
-- 1) Find the 5 oldest users.
select id, username, created_at
from users
order by created_at
limit 5;

-- 2) What day of the week do most users register on? We need to figure out when to schedule an ad campaign.

select dayname(created_at), count(dayname(created_at))
from users
group by dayname(created_at)
order by count(dayname(created_at)) desc
limit 4;   --  Thursday and Sunday are having more number of registrations so we can schedule an ad campaign

-- 3) We want to target our inactive users with an email campaign.Find the users who have never posted a photo

select * from photos;
select * from photo_tags;
select id, (username) from users where id not in (select user_id from photos);

-- 4) We're running a new contest to see who can get the most likes on a single photo.WHO WON??!!
select * from likes;
select photo_id, count(user_id) as likes from likes
group by photo_id
order by likes desc;

-- 5) Our Investors want to know… How many times does the average user post?HINT - *total number of photos/total number of users*
 select count(*) from photos;
with t1 as
(select count(id) as No_of_photos, (select count(*) from users) as tot_users
 from photos)
 select No_of_photos/tot_users as avg_posts from t1 ;
 
 -- 6) user ranking by postings higher to lower
with c as
(select user_id, count(user_id) as count
from photos
group by user_id)
select *, rank() over (order by count desc) as ranking from c;

-- 7) total numbers of users who have posted at least one time.
with cte2 as 
(select user_id, count(user_id) as No_of_Posts
from photos
group by user_id)
select count(user_id) as No_of_Users from cte2;

-- 8) A brand wants to know which hashtags to use in a post
-- What are the top 5 most commonly used hashtags?

with cte1 as
(select tag_id, count(tag_id) as tot_count from photo_tags
group by tag_id), 
cte2 as
(select tag_name, id from tags)
select * from cte1
join cte2
on cte1.tag_id = cte2.id
order by tot_count desc;

-- alternate way
select tag_id, t.tag_name, count(tag_id) as tot_count from photo_tags as pt
inner join tags as t
on pt.tag_id = t.id
group by tag_id
order by tot_count desc;

-- 9) We have a small problem with bots on our site...Find users who have liked every single photo on the site.

select * from
(select likes.user_id, count(*) as cnt from likes
join photos
on likes.photo_id = photos.id
group by likes.user_id) as temp
where cnt = 257;

-- select * from likes;
-- select * from photos;
-- select * from users;

-- 10) Find users who have never commented on a photo.

select * from users
where id not in (select user_id from comments);




