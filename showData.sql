use Group12_Project;

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

OPEN SYMMETRIC KEY Group12_SymmetricKey
DECRYPTION BY CERTIFICATE Group12_Certificate;

SELECT top 3 username, convert(varchar, DecryptByKey(encryptedPassword)) as 'Password' from Users;

CLOSE SYMMETRIC KEY Group12_SymmetricKey;


SELECT  a.name AS [TABLE NAME] ,
        b.rows AS [RECORD COUNT]
FROM    sysobjects AS a
        INNER JOIN sysindexes AS b ON a.id = b.id
WHERE   ( a.type = 'u' )
        AND ( b.indid IN ( 0, 1 ) )
ORDER BY a.name ,
        b.rows DESC

select top 10 * from MediaCount order by like_counts desc;


-- SET NOCOUNT On
-- Declare @Start int = (select min(media_id) from Media);
-- Declare @End int = (select max(media_id) from Media);
-- while @Start <= @End 
-- BEGIN
--     if (rand() < 0.7)
--         update Media set location_id = 471 + cast(rand() * 26 as int) where media_id = @Start;
--     else
--         update Media set location_id = 494 where media_id = @Start;

--     Set @Start += 1;
-- End

select location_id, count(*) as [count] from Media group by location_id order by location_id;

select * from [Location];


select top 3 Media.media_id, count(*) as [CommentCount]
from Media 
join Comments
on Media.media_id = Comments.media_id
group by Media.media_id
order by count(*) desc;


select top 3 Media.media_id, count(*) as [LikeCount]
from Media 
join Likes
on Media.media_id = Comments.media_id
group by Media.media_id
order by count(*) desc;


go
