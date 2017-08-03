Delimiter ;;
Drop procedure if exists getFansNew;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getFansNew`(IN `userid` INT,IN `profileid` INT, IN `limiter` INT, IN `skip` INT, IN `timestamp` BIGINT)
    NO SQL
BEGIN

set @userid=userid;
set @limiter=limiter;
set @skip=skip;

set @lat=(Select latitude from User_tbl where user_id=@userid);

set @lon=(Select longitude from User_tbl where user_id=@userid);
if(@lat is not null) then 
Begin
drop table if exists userplaymates;
Create temporary table userplaymates
(
user_id int,
user_name varchar(200),
profile_image varchar(2000),
Gender varchar(50),
Age int,
distance double(10,1),
IsPlaymate int null
);

set @t1=Concat("Insert into userplaymates(user_id,user_name,profile_image,Gender,Age,distance)
               Select ut.user_id,user_name,profile_photo_path as profile_image,
               Gender, TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS Age,
               ( 1.609344*3959 * acos( cos( radians(",@lat,") ) * cos( radians( ut.latitude ) ) 
   * cos( radians(ut.longitude) - radians(",@lon,")) + sin(radians(",@lat,")) 
   * sin( radians(ut.latitude)))) AS distance 
from User_Playmates_tbl upt
inner join User_tbl ut
on upt.Userid=ut.user_id
where upt.frienduserid=",profileid,"
and upt.status=0
group by ut.user_id,user_name,profile_image,Gender limit ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;



drop  temporary table if exists userPlaymateCount;
Create temporary table userPlaymateCount
Select distinct udt.user_id,(count(*)-1)/2 as PlaymateCount
from userplaymates udt
left join User_Playmates_tbl upt
on upt.userid=udt.user_id
and status=1
group by udt.user_id;

drop  temporary table if exists userFanCount;
Create temporary table userFanCount
Select distinct udt.user_id,count(*) as FanCount
from userplaymates udt
left join User_Playmates_tbl upt
on upt.frienduserid=udt.user_id
and status=0
group by udt.user_id;



drop  temporary table if exists userActivityTemp;
Create temporary table userActivityTemp
Select distinct udt.user_id,min(evt.EventId) as EventId
from userplaymates udt
left join Event_Joinees_tbl ejt
on ejt.Userid=udt.user_id
left join Event_tbl evt
on evt.EventId=ejt.EventID
and Start_Date>@currenttime
group by udt.user_id;

drop  temporary table if exists userActivity;
Create temporary table userActivity
Select distinct udt.user_id,evt.EventId,Start_date,GameId
from userActivityTemp udt
left join Event_tbl evt
on evt.EventId=udt.EventID;

Update userplaymates udt
set IsPlaymate=1
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.userid=@userid
and upt.frienduserid=udt.user_id
and status=1
);

Select distinct udt.*,
PlaymateCount,
FanCount,
GameId,
Unix_TimeStamp(Start_Date) as Start_Date,
EventId
from userplaymates udt
inner join userPlaymateCount upt
on upt.user_id=udt.user_id
inner join userFanCount ufc
on ufc.user_id=udt.user_id
inner join userActivity uat
on uat.user_id=udt.user_id;
End;
else
Begin
drop table if exists userplaymates;
Create temporary table userplaymates
(
user_id int,
user_name varchar(200),
profile_image varchar(2000),
Gender varchar(50),
Age int,
distance double(10,1),
IsPlaymate int null
);

set @t1=Concat("Insert into userplaymates(user_id,user_name,profile_image,Gender,Age,distance)
               Select ut.user_id,user_name,profile_photo_path as profile_image,
               Gender, TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS Age,
               'NA' AS distance 
from User_Playmates_tbl upt
inner join User_tbl ut
on upt.Userid=ut.user_id
where upt.frienduserid=",profileid,"
and upt.status=0
group by ut.user_id,user_name,profile_image,Gender limit ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;

drop  temporary table if exists userPlaymateCount;
Create temporary table userPlaymateCount
Select distinct udt.user_id,(count(*)-1)/2 as PlaymateCount
from userplaymates udt
left join User_Playmates_tbl upt
on upt.userid=udt.user_id
and status=1
group by udt.user_id;

drop  temporary table if exists userFanCount;
Create temporary table userFanCount
Select distinct udt.user_id,count(*) as FanCount
from userplaymates udt
left join User_Playmates_tbl upt
on upt.frienduserid=udt.user_id
and status=0
group by udt.user_id;



drop  temporary table if exists userActivityTemp;
Create temporary table userActivityTemp
Select distinct udt.user_id,min(evt.EventId) as EventId
from userplaymates udt
left join Event_Joinees_tbl ejt
on ejt.Userid=udt.user_id
left join Event_tbl evt
on evt.EventId=ejt.EventID
and Start_Date>@currenttime
group by udt.user_id;

drop  temporary table if exists userActivity;
Create temporary table userActivity
Select distinct udt.user_id,evt.EventId,Start_date,GameId
from userActivityTemp udt
left join Event_tbl evt
on evt.EventId=udt.EventID;

Update userplaymates udt
set IsPlaymate=1
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.userid=@userid
and upt.frienduserid=udt.user_id
and status=1
);


Select distinct udt.user_id,udt.user_name,udt.profile_image,udt.Gender,udt.Age,'NA' as distance,PlaymateCount,
FanCount,
GameId,
Unix_TimeStamp(Start_Date) as Start_Date,
EventId,
IsPlaymate
from userplaymates udt
inner join userPlaymateCount upt
on upt.user_id=udt.user_id
inner join userFanCount ufc
on ufc.user_id=udt.user_id
inner join userActivity uat
on uat.user_id=udt.user_id;
End;

End if;

  END