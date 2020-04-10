
-- drop database Group12_Project;
-- GO

-- create database Group12_Project;
-- GO

Use Group12_Project;

DROP TABLE Video 
DROP TABLE Photo 
DROP TABLE Media_Tags 
DROP TABLE Tags 
DROP TABLE FollowInfo 
DROP TABLE BlockInfo 
DROP TABLE UserCount 
DROP TABLE Comments 
DROP TABLE Likes 
DROP TABLE Views 
DROP TABLE UserSettings 
DROP TABLE MediaCount
DROP TABLE Media
DROP TABLE Users 
DROP TABLE Location


create table Users(
    user_id int IDENTITY primary Key,
    username varchar(50),
    email varchar(50),
    encryptedPassword varchar(250)
);


create table UserCount (
    user_count_id int IDENTITY primary Key,
    user_id int not null REFERENCES Users(user_id),
    --- media_counts int, computed column
    -- followers_counts int, computed column
    -- following_counts int, computed column
);

create table UserSettings (
    settings_id int IDENTITY primary Key,
    user_id int not null REFERENCES Users(user_id),
    is_private_user bit,
    mute_notification bit
)

create table FollowInfo(
    follow_id int IDENTITY primary Key,
    user_id int not null REFERENCES Users(user_id),
    follower_id int not null REFERENCES Users(user_id)
)

create table BlockInfo(
    block_id int IDENTITY primary Key,
    user_id int not null REFERENCES Users(user_id),
    fieldblocker_id int not null REFERENCES Users(user_id)
)

CREATE TABLE Location(
   location_id  int primary key IDENTITY(1,1),
   latitude varchar(20),
   longtitude varchar(20),
   address varchar(250),
   name varchar(10) 
)


CREATE TABLE Media
(	media_id INT PRIMARY KEY IDENTITY (1, 1),
    create_time DATETIME NOT NULL,
    text VARCHAR(50),
    location_id INT,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (location_id) REFERENCES Location (location_id)
)
CREATE TABLE MediaCount(
   media_count_id  int primary key IDENTITY(1,1),
   media_id INT NOT NULL,
   --like_counts int NOT NULL,
   --view_counts int NOT NULL,
   --commnet_counts int NOT NULL
 FOREIGN KEY (media_id) REFERENCES Media (media_id)
)

CREATE TABLE Photo
(	media_id INT PRIMARY KEY,
    photo_url VARCHAR(50) NOT NULL,
    FOREIGN KEY (media_id) REFERENCES Media (media_id)
)

CREATE TABLE Video
(	media_id INT PRIMARY KEY,
	resolution VARCHAR(20),
    video_url VARCHAR(50) NOT NULL
    FOREIGN KEY (media_id) REFERENCES Media (media_id)
)


CREATE TABLE Tags
(	tag_id INT PRIMARY KEY IDENTITY (1, 1),
    content VARCHAR(50)
)


CREATE TABLE Media_Tags
(	tag_id INT,
    media_id INT,
    PRIMARY KEY(tag_id, media_id),
    FOREIGN KEY (media_id) REFERENCES Media (media_id),
    FOREIGN KEY (tag_id) REFERENCES Tags (tag_id)
)


CREATE TABLE Likes
(
like_id int primary key IDENTITY(1,1),
user_id int NOT NULL,
media_id int NOT NULL,
created_time varchar(10) NOT NULL,
FOREIGN KEY (user_id) REFERENCES Users(user_id),
FOREIGN KEY(media_id) REFERENCES Media(media_id)
)

CREATE TABLE Comments
(
comment_id int primary key IDENTITY(1,1),
user_id int NOT NULL,
media_id int NOT NULL,
comment_text varchar(50)  NOT NULL,
created_time varchar(10) NOT NULL,
FOREIGN KEY (user_id) REFERENCES Users(user_id),
FOREIGN KEY(media_id) REFERENCES Media(media_id)
)

CREATE TABLE Views
(
views_id int primary key IDENTITY(1,1),
user_id int NOT NULL,
media_id int NOT NULL,
created_time varchar(10) NOT NULL,
FOREIGN KEY (user_id) REFERENCES Users(user_id),
FOREIGN KEY(media_id) REFERENCES Media(media_id)
)


--- Create Computed Columns with functions

CREATE FUNCTION fn_CalcMediaCount(@UserId INT)
RETURNS INT
AS
   BEGIN
      DECLARE @total int =
         (SELECT Count(media_id)
          FROM Media
          WHERE  user_id = @UserId);
      SET @total = ISNULL(@total, 0);
      RETURN @total;
END

CREATE FUNCTION fn_CalcFollowers(@UserId INT)
RETURNS INT
AS
   BEGIN
      DECLARE @total int =
         (SELECT Count(follow_id)
          FROM FollowInfo
          WHERE  user_id = @UserId);
      SET @total = ISNULL(@total, 0);
      RETURN @total;
END


CREATE FUNCTION fn_CalcFollowing(@UserId INT)
RETURNS INT
AS
   BEGIN
      DECLARE @total int =
         (SELECT Count(follow_id)
          FROM FollowInfo
          WHERE  follower_id = @UserId);
      SET @total = ISNULL(@total, 0);
      RETURN @total;
END


DROP FUNCTION fn_CalcLikes;
CREATE FUNCTION fn_CalcLikes(@Media_Id INT)
RETURNS INT
AS
   BEGIN
      DECLARE @total int =
         (SELECT Count(like_id)
          FROM Likes
          WHERE  media_id = @Media_Id);
      SET @total = ISNULL(@total, 0);
      RETURN @total;
END


DROP FUNCTION fn_CalcComments;
CREATE FUNCTION fn_CalcComments(@Media_Id INT)
RETURNS INT
AS
   BEGIN
      DECLARE @total int =
         (SELECT Count(c.comment_id )
          FROM Comments c 
          WHERE  media_id = @Media_Id);
      SET @total = ISNULL(@total, 0);
      RETURN @total;
END


DROP FUNCTION fn_CalcViews;
CREATE FUNCTION fn_CalcViews(@Media_Id INT)
RETURNS INT
AS
   BEGIN
      DECLARE @total int =
         (SELECT Count(v.views_id )
          FROM Views v 
          WHERE  media_id = @Media_Id);
      SET @total = ISNULL(@total, 0);
      RETURN @total;
END


Alter table MediaCount Add like_counts AS (dbo.fn_CalcLikes(media_id));
Alter table MediaCount Add comment_counts AS (dbo.fn_CalcComments(media_id));
Alter table MediaCount Add view_counts AS (dbo.fn_CalcViews(media_id));
Alter table UserCount Add followers_counts AS (dbo.fn_CalcFollowers(user_id));
Alter table UserCount Add following_counts AS (dbo.fn_CalcFollowing(user_id));
Alter table UserCount Add media_counts As(dbo.fn_CalcMediaCount(user_id));


-- Use Table-Level CHECK Constraint to implement business rules

CREATE FUNCTION CheckBlockInfo (@UserId varchar(30))
RETURNS smallint
AS
BEGIN
   DECLARE @Count smallint=0;
   SELECT @Count = COUNT(block_id) 
          FROM BlockInfo
          WHERE fieldblocker_id = @UserId
   RETURN @Count;
END;


ALTER TABLE Media ADD CONSTRAINT BanBlockUsers CHECK (dbo.CheckBlockInfo(user_id) < 10);

--- create view
drop view user_media;

create view user_media as 
select media_id, Users.username, text
from Users
join Media
on Users.user_id = media.user_id;

drop view [user_block];
create view user_block as
select b.fieldblocker_id as UserID, count(*) as BlockCount
from BlockInfo b
group by b.fieldblocker_id;

