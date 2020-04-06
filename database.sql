
use Group12_Projects;
drop database Group12_Project;

create database Group12_Project;
go

use Group12_Project;
GO


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

CREATE TABLE MediaCount(
   media_count_id  int primary key IDENTITY(1,1),
   like_counts int NOT NULL,
   view_counts int NOT NULL,
   commnet_counts int NOT NULL
)

CREATE TABLE Media
(	media_id INT PRIMARY KEY IDENTITY (1, 1),
    create_time DATETIME NOT NULL,
    media_count_id INT NOT NULL,
    text VARCHAR(50),
    location_id INT,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (location_id) REFERENCES Location (location_id),
    FOREIGN KEY (media_count_id) REFERENCES MediaCount (media_count_id)
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
Go

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


GO

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

go

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

go

Alter table UserCount Add followers_counts AS (dbo.fn_CalcFollowers(user_id));
Alter table UserCount Add following_counts AS (dbo.fn_CalcFollowing(user_id));
Alter table UserCount Add media_counts As(dbo.fn_CalcMediaCount(user_id));
go


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

go

ALTER TABLE Media ADD CONSTRAINT BanBlockUsers CHECK (dbo.CheckBlockInfo(user_id) < 10);


go

--- encrypt
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'as#21ef2!werxwer02921s23987hx';

CREATE CERTIFICATE Group12Certificate
WITH SUBJECT = 'Database group 12 project demo',
EXPIRY_DATE = '2030-1-31';

-- Create symmetric key to encrypt data
CREATE SYMMETRIC KEY Group12SymmetricKey
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE Group12Certificate;

-- Open symmetric key
OPEN SYMMETRIC KEY Group12SymmetricKey
DECRYPTION BY CERTIFICATE Group12Certificate;


-- Add Users, FollowInfo & BlockInfo
Declare @Counter int = 1;

while @Counter <= 12 BEGIN
    Declare @CounterStr varchar(20) = cast(@Counter as varchar);
    INSERT INTO Users VALUES
    ('User ' + @CounterStr, 
    'user' + @CounterStr + '@gmail.com', 
     EncryptByKey(Key_GUID(N'Group12SymmetricKey'), 
    'password' +  @CounterStr));

    DECLARE @UserId int = SCOPE_IDENTITY()

    INSERT INTO UserCount VALUES(@UserId);
    INSERT INTO UserSettings VALUES(@UserId, 1, 0);

    if (@Counter > 1)
        Insert Into FollowInfo VALUES(@UserId, @UserId-1);
    if (@Counter > 2)
        Insert Into FollowInfo VALUES(@UserId, @UserId-2);
    
    if (@Counter != 1)
        Insert Into BlockInfo Values(@UserId, 1);

    SET @Counter += 1;
END


--Add meida
Declare @Counter int = 1;
Declare @UserId int;

while @Counter <= 30 BEGIN
	Declare @CounterStr varchar(20) = cast(@Counter as varchar);
    Declare @rdate DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2018-01-01');
    SELECT @UserId = u2.user_id FROM Users u2 t WHERE u2.user_id = Cast(RAND()*(12-1)+1 as int);
    INSERT INTO Media VALUES
    (@rdate, 
           ,
    'text' +  @CounterStr,
    @UserId);

    SET @Counter += 1;
END

--Add Tags
Declare @Counter int = 1;
while @Counter <= 15 BEGIN
	Declare @CounterStr varchar(20) = cast(@Counter as varchar);
    INSERT INTO Tags VALUES
    ('Content ' +  @CounterStr);
    SET @Counter += 1;
END

SELECT *
FROM Tags t 

--Add Media_Tags
Declare @cnt int = 1;
Declare @TagId int;
Declare @MediaId int;

while @cnt <= 10 BEGIN
	SELECT @TagId = t.tag_id FROM Tags t WHERE t.tag_id = Cast(RAND()*(15-1)+1 as int);
	SELECT @MediaId =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(30-1)+1 as int);
	INSERT INTO Media_Tags VALUES
    (@TagId, @MediaId);
	SET @cnt += 1;
END
--Photo
Declare @cnt int = 1;
Declare @MediaId int;

while @cnt <= 10 BEGIN
	SELECT @MediaId =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(15-1)+1 as int);
	Declare @MediaStr varchar(20) = cast(@MediaId as varchar);
	INSERT  Into Photo VALUES
	(@MediaId, 'URL for ' + @MediaStr);
	SET @cnt += 1;
END
--Video
Declare @cnt int = 1;
Declare @MediaId int;

while @cnt <= 10 BEGIN
	SELECT @MediaId =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(30-16)+16 as int);
	Declare @MediaStr varchar(20) = cast(@MediaId as varchar);
	Declare @CntStr varchar(20) = cast(@cnt as varchar);
	INSERT  Into Video VALUES
	(@MediaId,'Resolution ' + @CntStr,'URL for ' + @MediaStr);
	SET @cnt += 1;
END

   
   
   
---------------------------------
INSERT  Location (
   latitude,
   longtitude,
   address,
   name
)
 VALUES 
( '73','23','213 pontius','zyl'),
 ( '78','23','213 pontius','zs'),
 ( '70','23','213 pontius','dl'),
 ( '71','23','213 pontius','fh'),
( '80','33','213 pontius','xf'),
 ( '93','23','213 pontius','yy'),
 ( '33','23','213 pontius','lzh'),
 ('53','43','213 pontius','zx'),
 ( '63','23','213 pontius','sfc'),
( '23','23','213 pontius','hzy');


INSERT MediaCount (
   
   like_counts,
   view_counts,
   commnet_counts
)
 VALUES (1,2,4),
(6,32,12),
 (12,54,77),
(3,66,44),
(12,45,32),
(3,1,7),
 (6,8,9),
 (22,55,99),
 (20,10,19),
 (12,23,65);


INSERT INTO Media (
    create_time,
    media_count_id,
    text,
    location_id,
    user_id
)
VALUES
    ('20180601',1,'post1 user1',1,5),
    ('20180602',2,'post1 user1',2,2),
    ('20180603',3,'post1 user3',3,3),
    ('20180604',4,'post1 user4',4,4),
    ('20180605', 5,'post1 user5',1,6),
    ('20180606', 6,'post1 user6',1,7),
    ('20180607', 7,'post1 user7',1,8),
    ('20180608', 8,'post1 user8',1,2),
    ('20180609', 9,'post1 user9',1,2),
    ('20180611', 10,'post1 user10',1,2),
    ('20180612', 11,'post1 user11',1,2),
    ('20180613', 12,'post1 user12',1,2),
    ('20180614', 13,'post1 user13',1,2),
    ('20180615', 14,'post1 user14',1,2),
    ('20180616', 15,'post1 user15',1,2),
    ('20180617', 16,'post1 user16',1,3),
    ('20180618', 17,'post1 user17',1,4),
    ('20180619', 18,'post1 user18',1,7),
    ('20180620', 19,'post1 user19',1,6),
    ('20180621', 20,'post1 user21',1,4),
    ('20180622', 1,'post2 user1',1,2),
    ('20180623', 14,'post2 user14',1,4),
    ('20180624', 18,'post2 user18',1,4)
    ;

   


INSERT  Likes (

   user_id,
  media_id,
 created_time
)
 VALUES (1,1,'8'),
(2,2,'28'),
 (3,3,'49'),
(4,4,'28'),
(5,5,'34'),
(6,6,'54'),
 (7,7,'8'),
 (8,8,'18'),
(9,9,'27'),
 (10,10,'8');



INSERT  Comments (

   user_id,
  media_id,
 comment_text,
 created_time
)
 VALUES (1,1,'lzy','8'),
        (2,2,'liu','28'),
        (3,3,'liu','49'),
        (4,4,'liu','28'),
        (5,5,'liu','34'),
        (6,6,'liu','54'),
        (7,7,'liu','8'),
        (8,8,'liu', '34'),
        (9,9,'liu','27'),
        (10,10,'liu','8');





INSERT  Views (

   user_id,
  media_id,
 created_time
)
 VALUES (1,1,'8'),
(2,2,'28'),
 (3,3,'49'),
(4,4,'28'),
(5,5,'34'),
(6,6,'54'),
 (7,7,'8'),
 (8,8,'18'),
(9,9,'27'),
 (10,10,'8');


SELECT top 3 username, convert(varchar, DecryptByKey(encryptedPassword)) as 'Password' from Users;

select * from UserCount;

select * from FollowInfo;

select * from BlockInfo;

select dbo.CheckBlockInfo(1) as blocker;


-- user 1 cannot create any media
INSERT INTO Media (create_time, media_count_id, text, location_id, user_id)
VALUES('20180601',1,'post1 user1',1,1);
go


---CLOSE SYMMETRIC KEY Group12SymmetricKey;

-- Drop the symmetric key
---DROP SYMMETRIC KEY Group12Certificate;

-- Drop the certificate
---DROP CERTIFICATE Group12Certificate;

--Drop the DMK
---DROP MASTER KEY;
