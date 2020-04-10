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

select count(*) from UserCount;

select count(*) from FollowInfo;

select count(*) from BlockInfo;

select count(*) from Media;

select dbo.CheckBlockInfo(1) as blocker;

select top 10 * from MediaCount order by like_counts desc;

go
