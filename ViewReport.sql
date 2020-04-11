--- create view
Use Group12_Project;

drop view view_followerCount;
drop view view_followingCount;
drop view view_user_media;
drop view view_user_block;
drop view view_location_post;

go 

create view view_followerCount as
select user_id, count(follower_id) as 'FollowerCount'
from FollowInfo
group by user_id;

go

select top 3 * from view_followerCount 
order by FollowerCount desc;

go 

create view view_followingCount as
select follower_id, count(*) as 'FollowingCount'
from FollowInfo
group by follower_id;

go

select top 3 * from view_followingCount 
order by FollowingCount desc;



go

create view view_user_media as 
select media_id, Users.username, text
from Users
join Media
on Users.user_id = media.user_id;

go

select top 3 * from user_media;

go

create view view_user_block as
select b.fieldblocker_id as UserID, count(*) as BlockCount
from BlockInfo b
group by b.fieldblocker_id;

GO

select top 3 * from view_user_block order by BlockCount desc;

GO

create view view_location_post as
select l.name as LocationName, count(*) as [PostCount] 
from Media m
join Location l
on m.location_id = l.location_id
group by l.name;

GO

select top 3 * from view_location_post
order by PostCount desc;

GO

-- select Users.user_id, FollowInfo.user_id as FeedID
-- from Users
-- join FollowInfo
-- on Users.user_id = FollowInfo.follower_id
-- join Media
-- on Media.user_id = FollowInfo.follower_id;

