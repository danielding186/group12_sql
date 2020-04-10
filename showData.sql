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


SELECT top 3 username, convert(varchar, DecryptByKey(encryptedPassword)) as 'Password' from Users;

select * from UserCount;

select count(*) from FollowInfo;

select * from BlockInfo;

select dbo.CheckBlockInfo(1) as blocker;

go
