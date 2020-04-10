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

SELECT *
FROM Users
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

SELECT *
FROM MediaCount

-- Add Users, FollowInfo & BlockInfo
Declare @CounterUser int = 1;

while @CounterUser <= 12 BEGIN
    Declare @CounterStrU varchar(20) = cast(@CounterUser as varchar);
    INSERT INTO Users VALUES
    ('User ' + @CounterStrU, 
    'user' + @CounterStrU + '@gmail.com', 
     EncryptByKey(Key_GUID(N'Group12SymmetricKey'), 
    'password' +  @CounterStrU));

    DECLARE @UserIdU int = SCOPE_IDENTITY()

    INSERT INTO UserCount VALUES(@UserIdU);
    INSERT INTO UserSettings VALUES(@UserIdU, 1, 0);

    if (@CounterUser > 1)
        Insert Into FollowInfo VALUES(@UserIdU, @UserIdU-1);
    if (@CounterUser > 2)
        Insert Into FollowInfo VALUES(@UserIdU, @UserIdU-2);
    
    if (@CounterUser != 1)
        Insert Into BlockInfo Values(@UserIdU, 1);

    SET @CounterUser += 1;
END

--Location
Declare @CounterLocation int = 1;
while @CounterLocation <= 10 
BEGIN
	Declare @LatitudeStr varchar(20) = cast(@CounterLocation as varchar);
	Declare @LongtitudeStr varchar(20) = cast(@CounterLocation as varchar);
    INSERT INTO Location VALUES( @LatitudeStr, @LongtitudeStr,'123pontius','sz');
    SET @CounterLocation += 1;
END


--Add meida
Declare @CounterM int = 1;
Declare @UserIdM int;
Declare @LocationIdM int;

while @CounterM <= 30 BEGIN
    Declare @CounterStrM varchar(20) = cast(@CounterM as varchar);
    Declare @rdateM DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2018-01-01');
    SELECT @UserIdM = u2.user_id FROM Users u2 WHERE u2.user_id = Cast(RAND()*(12-1)+1 as int);
    SELECT @LocationIdM = l.location_id FROM Location l WHERE l.location_id = Cast(RAND()*(12-1)+1 as int);
    INSERT INTO Media VALUES
    (@rdateM, 
    'text',@LocationIdM,
    @UserIdM);

    SET @CounterM += 1;
END 

--MediaCount
Declare @CounterMC int = 1;
Declare @MediaId int;

while @CounterMC <= 30 BEGIN
    SELECT @MediaId =m.media_id FROM Media m WHERE m.media_id = @CounterMC;
    INSERT INTO MediaCount VALUES
    (@MediaId);
    SET @CounterMC += 1;
END 

--Add Tags
Declare @CounterT int = 1;
while @CounterT <= 15 BEGIN
	Declare @CounterStrTag varchar(20) = cast(@CounterT as varchar);
    INSERT INTO Tags VALUES
    ('Content ' +  @CounterStrTag);
    SET @CounterT += 1;
END 

--Add Media_Tags
Declare @cntMT int = 1;
Declare @TagIdMT int;
Declare @MediaIdMT int;

while @cntMT <= 10 BEGIN
	SELECT @TagIdMT = t.tag_id FROM Tags t WHERE t.tag_id = Cast(RAND()*(15-1)+1 as int);
	SELECT @MediaIdMT =m2.media_id FROM Media m2 WHERE m2.media_id = Cast(RAND()*(30-1)+1 as int);
	INSERT INTO Media_Tags VALUES
    (@TagIdMT, @MediaIdMT);
	SET @cntMT += 1;
END

--Photo
Declare @cntP int = 1;
Declare @MediaIdP int;

while @cntP <= 15 BEGIN
	SELECT @MediaIdP =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(30-1)+1 as int);
	IF EXISTS (SELECT p.media_id FROM Photo p WHERE p.media_id = @MediaIdP) 
	BEGIN
		SET @cntP += 1;
	END
	ELSE
	BEGIN
	    Declare @MediaStrP varchar(20) = cast(@MediaIdP as varchar);
		INSERT  Into Photo VALUES
		(@MediaIdP, 'URL for ' + @MediaStrP);
		SET @cntP += 1;
	END
END

--Video
Declare @cntV int = 1;
Declare @MediaIdV int;

while @cntV <= 30 BEGIN
	SELECT @MediaIdV =m.media_id FROM Media m WHERE m.media_id = @cntV;
	IF EXISTS (SELECT v.media_id FROM Video v WHERE v.media_id = @MediaIdV) 
	BEGIN
		SET @cntV += 1;
	END
	ELSE IF EXISTS(SELECT p.media_id FROM Photo p WHERE p.media_id = @cntV)
	BEGIN
		SET @cntV += 1;
	END
	ELSE
	BEGIN
		Declare @MediaStrV varchar(20) = cast(@MediaIdV as varchar);
		Declare @CntStrV varchar(20) = cast(@cntV as varchar);
		INSERT  Into Video VALUES
		(@MediaIdV,'Resolution ' + @CntStrV,'URL for ' + @MediaStrV);
		SET @cntV += 1;
	END
END

--Likes
Declare @CounterLike int = 1;
Declare @UserIdLike int;
Declare @MediaIdLike int;

while @CounterLike <= 40 BEGIN
	SELECT @MediaIdLike =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(30-1)+1 as int);
	SELECT @UserIdLike = u2.user_id FROM Users u2  WHERE u2.user_id = Cast(RAND()*(12-1)+1 as int);
    Declare @CtimeLike DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2020-02-02');
	INSERT  Into Likes VALUES
	(@UserIdLike, @MediaIdLike,@CtimeLike);
	SET @CounterLike += 1;
END

--Comments
Declare @CounterCom int = 1;
Declare @UserIdCom int;
Declare @MediaIdCom int;

while @CounterCom <= 40 BEGIN
	SELECT @MediaIdCom =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(30-1)+1 as int);
	SELECT @UserIdCom = u2.user_id FROM Users u2  WHERE u2.user_id = Cast(RAND()*(12-1)+1 as int);
    Declare @CtimeCom DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2020-02-02');
	INSERT  Into Comments VALUES
	(@UserIdCom, @MediaIdCom,'text',@CtimeCom);
	SET @CounterCom += 1;
END

--Views

Declare @CounterView int = 1;
Declare @UserIdView int;
Declare @MediaIdView int;

while @CounterView <= 40 BEGIN
	SELECT @MediaIdView =m.media_id FROM Media m WHERE m.media_id = Cast(RAND()*(30-1)+1 as int);
	SELECT @UserIdView = u2.user_id FROM Users u2  WHERE u2.user_id = Cast(RAND()*(12-1)+1 as int);
    Declare @CtimeView DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2020-02-02');
	INSERT  Into Views VALUES
	(@UserIdView, @MediaIdView,@CtimeView);
	SET @CounterView += 1;
END

SELECT *
FROM Media 
SELECT *
FROM MediaCount
SELECT *
FROM Comments 

SELECT *
FROM Photo 
SELECT *
FROM Video

SELECT *
FROM Tags
SELECT *
FROM Media_Tags 


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