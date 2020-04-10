
use Group12_Project;

delete from UserCount;
delete from MediaCount;
delete from FollowInfo;
delete from BlockInfo;
delete from UserSettings;
delete from Media_Tags;
delete from Tags;
delete from Likes;
delete from Comments;
delete from Views;
delete from Video;
delete from Photo;
delete from Media;
delete from Location;
delete from Users;

SET NOCOUNT On
--- encrypt
if not exists (SELECT name FROM sys. symmetric_keys where name = 'Group12_SymmetricKey') BEGIN
    CREATE MASTER KEY
    ENCRYPTION BY PASSWORD = 'as#21ef2!werxwer02921s23987hx';

    CREATE CERTIFICATE Group12_Certificate
    WITH SUBJECT = 'Database group 12 project demo',
    EXPIRY_DATE = '2030-1-31';

    -- Create symmetric key to encrypt data
    CREATE SYMMETRIC KEY Group12_SymmetricKey
    WITH ALGORITHM = AES_128
    ENCRYPTION BY CERTIFICATE Group12_Certificate;
END

-- Open symmetric key
OPEN SYMMETRIC KEY Group12_SymmetricKey
DECRYPTION BY CERTIFICATE Group12_Certificate;

-- Add Users, FollowInfo & BlockInfo
Declare @CounterUser int = 1;
Declare @minUserID int = -1;

while @CounterUser <= 1000 BEGIN
    Declare @CounterStrU varchar(20) = cast(@CounterUser as varchar);
    INSERT INTO Users VALUES
    ('User ' + @CounterStrU, 
    'user' + @CounterStrU + '@gmail.com', 
     EncryptByKey(Key_GUID(N'Group12_SymmetricKey'), 
    'password' +  @CounterStrU));

    DECLARE @UserIdU int = SCOPE_IDENTITY()
    if (@minUserID = -1)
        set @minUserID = @UserIdU;

    INSERT INTO UserCount VALUES(@UserIdU);
    INSERT INTO UserSettings VALUES(@UserIdU, 1, 0);

    DECLARE @UserFollower int = 0;
    while rand() < 0.7 BEGIN
        set @UserFollower = (SELECT TOP 1 user_id FROM Users ORDER BY NEWID());
        if not exists (Select * from FollowInfo where user_id = @UserIdU and follower_id = @UserFollower)
            Insert into FollowInfo Values(@UserIdU, @UserFollower);
    END

    if (@CounterUser < 20 and @CounterUser != 1)
        Insert Into BlockInfo Values(@UserIdU, @minUserID);

    Declare @UserBlocker int = 0;
    if (rand() < 0.05) BEGIN
        set @UserBlocker = (SELECT TOP 1 user_id FROM Users ORDER BY NEWID());
        if (@UserBlocker != @UserIdU) and not exists (Select * from BlockInfo where user_id = @UserIdU and fieldblocker_id = @UserBlocker)
            Insert into BlockInfo Values(@UserIdU, @UserBlocker);
    END
        

    SET @CounterUser += 1;
END

-- SELECT top 3 username, convert(varchar, DecryptByKey(encryptedPassword)) as 'Password' from Users;

CLOSE SYMMETRIC KEY Group12_SymmetricKey;
-- DROP SYMMETRIC KEY Group12_Certificate;
-- DROP CERTIFICATE Group12_Certificate;
-- DROP MASTER KEY;

--Location
use Group12_Project;
drop table #LocationSample;
CREATE TABLE #LocationSample (
    loc_id int IDENTITY primary Key, 
    cityName varchar(30) not NULL,
    latitude varchar(30) not null,
    longtitude varchar(30) not NULL);
Insert into #LocationSample
 values('New york', '40.670', '-73.940'), ('Los angeles', '34.110', '-118.410'),
  ('Chicago', '41.840', '-87.680'), ('Houston', '29.770', '-95.390'),
  ('Philadelphia', '40.010', '-75.130'), ('Phoenix', '33.540', '-112.070'),
  ('San diego', '32.810', '-117.140'), ('San antonio', '29.460', '-98.510'),
  ('Dallas', '32.790', '-96.770'), ('Detroit', '42.380', '-83.100'),
  ('San jose', '37.300', '-121.850'), ('Jacksonville', '30.330', '-81.660'),
  ('Indianapolis', '39.780', '-86.150'), ('San francisco', '37.770', '-122.450'),
  ('Columbus', '39.990', '-82.990'), ('Austin', '30.310', '-97.750'),
  ('Memphis', '35.110', '-90.010'), ('Baltimore', '39.300', '-76.610'),
  ('Fort worth', '32.750', '-97.340'), ('El paso', '31.850', '-106.440'),
  ('Charlotte', '35.200', '-80.830'), ('Milwaukee', '43.060', '-87.970'),
  ('Boston', '42.340', '-71.020'), ('Seattle', '47.620', '-122.350'),
  ('Denver', '39.770', '-104.870'), ('Washington', '38.910', '-77.020');

Declare @CounterLocation int = 1;
Declare @totalLocation int = (select count(*) from #LocationSample);
while @CounterLocation <= @totalLocation 
BEGIN
	Declare @LatitudeStr varchar(20) = (select latitude from #LocationSample where loc_id = cast(@CounterLocation as varchar));
	Declare @LongtitudeStr varchar(20) = (select longtitude from #LocationSample where loc_id = cast(@CounterLocation as varchar));
    Declare @CityStr varchar(20) = (select cityName from #LocationSample where loc_id = cast(@CounterLocation as varchar));
    
    INSERT INTO Location VALUES( @LatitudeStr, @LongtitudeStr,'123pontius', @CityStr);
    SET @CounterLocation += 1;
END

drop table #LocationSample;

--Add meida
Declare @CounterM int = 1;
Declare @UserIdM int;
Declare @LocationIdM int;

while @CounterM <= 3000 BEGIN
    Declare @CounterStrM varchar(20) = cast(@CounterM as varchar);
    Declare @rdateM DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2018-01-01');
    SELECT @UserIdM = (SELECT TOP 1 user_id FROM Users ORDER BY NEWID());
    SELECT @LocationIdM = (SELECT TOP 1 location_id FROM [Location] ORDER BY NEWID());
    
    INSERT INTO Media VALUES
    (@rdateM, 
    'text' + cast(@UserIdM as varchar),  @LocationIdM,
    @UserIdM);

    DECLARE @MediaId int = SCOPE_IDENTITY()
    
    if (rand() < 0.8)
        INSERT  Into Photo VALUES (@MediaId, 'Photo URL for ' + @CounterStrM);
    else
        INSERT  Into Video VALUES (@MediaId, 'Resolution ' + @CounterStrM, 'Video URL for ' + @CounterStrM);
    
    INSERT INTO MediaCount VALUES
    (@MediaId);

    SET @CounterM += 1;
END 

--Add Tags
Declare @CounterT int = 1;
while @CounterT <= 30 BEGIN
	Declare @CounterStrTag varchar(20) = cast(@CounterT as varchar);
    INSERT INTO Tags VALUES
    ('Content ' +  @CounterStrTag);
    SET @CounterT += 1;
END 

--Add Media_Tags
Declare @cntMT int = 1;
Declare @TagIdMT int;
Declare @MediaIdMT int;

while @cntMT <= 1000 BEGIN
	SELECT @TagIdMT = (SELECT TOP 1 tag_id FROM [Tags] ORDER BY NEWID());
	SELECT @MediaIdMT = (SELECT TOP 1 media_id FROM [Media] ORDER BY NEWID());
    if not exists (select * from Media_Tags where media_id = @MediaIdMT and tag_id = @TagIdMT)
	    INSERT INTO Media_Tags VALUES (@TagIdMT, @MediaIdMT);
	SET @cntMT += 1;
END

--Likes
Declare @CounterLike int = 1;
Declare @UserIdLike int;
Declare @MediaIdLike int;

while @CounterLike <= 10000 BEGIN
	SELECT @MediaIdLike = (SELECT TOP 1 media_id FROM [Media] ORDER BY NEWID());
	SELECT @UserIdLike = (SELECT TOP 1 user_id FROM Users ORDER BY NEWID());
    Declare @CtimeLike DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2020-02-02');
	INSERT  Into Likes VALUES
	(@UserIdLike, @MediaIdLike,@CtimeLike);
	SET @CounterLike += 1;
END

--Comments
Declare @CounterCom int = 1;
Declare @UserIdCom int;
Declare @MediaIdCom int;

while @CounterCom <= 500 BEGIN
	SELECT @MediaIdCom = (SELECT TOP 1 media_id FROM [Media] ORDER BY NEWID());
	SELECT @UserIdCom = (SELECT TOP 1 user_id FROM Users ORDER BY NEWID());
    Declare @CtimeCom DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2020-02-02');
	INSERT  Into Comments VALUES
	(@UserIdCom, @MediaIdCom, 'text', @CtimeCom);
	SET @CounterCom += 1;
END

--Views

Declare @CounterView int = 1;
Declare @UserIdView int;
Declare @MediaIdView int;

while @CounterView <= 10000 BEGIN
	SELECT @MediaIdView = (SELECT TOP 1 media_id FROM [Media] ORDER BY NEWID());
	SELECT @UserIdView = (SELECT TOP 1 user_id FROM Users ORDER BY NEWID());
    Declare @CtimeView DATE = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31), '2020-02-02');
	INSERT  Into Views VALUES
	(@UserIdView, @MediaIdView,@CtimeView);
	SET @CounterView += 1;
END