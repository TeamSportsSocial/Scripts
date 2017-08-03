Delimiter ;;
Drop procedure if exists getUserContacts;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserContacts`(IN `IUserId` INT,IN `limiter` INT, IN `skip` INT)
BEGIN


set @limiter=limiter;
set @skip=skip;


  Drop temporary table if exists userContacts;
Create temporary table userContacts
Select UserId,UserName,replace(replace(replace(replace(replace(Contact,' ',''),'-',''),'(',''),')',''),'+91','') as Contact
from UserContactDetails_tbl ucd
where userid=IUserId;


set @lat=(Select latitude from User_tbl where user_id=5);

set @lon=(Select longitude from User_tbl where user_id=5);

drop temporary table if exists userplaymates;
Create temporary table userplaymates
(
user_id int,
user_name varchar(200),
profile_image varchar(2000),
Gender varchar(50),
Age int,
IsPlaymate int null,
IsExistingUser int null,
Phone varchar(20) null
);


set @t1=Concat("Insert into userplaymates(user_id,user_name,profile_image,Gender,Age,IsExistingUser,Phone)
               Select ut.user_id,
 case when user_name is null then UserName else user_name end
 ,profile_photo_path as profile_image,
               Gender,TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS Age,
               case when ut.user_id is null then 0 else 1 end as IsExistingUser,
               Contact
from userContacts uct
left join User_tbl ut
on uct.Contact=ut.Mobile limit ");
set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;






drop  temporary table if exists userPlaymateCount;
Create temporary table userPlaymateCount
Select distinct udt.user_id,(count(*))/2 as PlaymateCount
from userplaymates udt
inner join User_Playmates_tbl upt
on upt.userid=udt.user_id
and status=1
group by udt.user_id;

drop  temporary table if exists userFanCount;
Create temporary table userFanCount
Select distinct udt.user_id,count(*) as FanCount
from userplaymates udt
inner join User_Playmates_tbl upt
on upt.frienduserid=udt.user_id
and status=0
group by udt.user_id;



drop  temporary table if exists userActivityTemp;
Create temporary table userActivityTemp
Select distinct udt.user_id,min(evt.EventId) as EventId
from userplaymates udt
inner join Event_Joinees_tbl ejt
on ejt.Userid=udt.user_id
inner join Event_tbl evt
on evt.EventId=ejt.EventID
and Start_Date>@currenttime
group by udt.user_id;

drop  temporary table if exists userActivity;
Create temporary table userActivity
Select distinct udt.user_id,evt.EventId,Start_date,GameId
from userActivityTemp udt
inner join Event_tbl evt
on evt.EventId=udt.EventID;

Update userplaymates udt
set IsPlaymate=1
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.userid=IUserid
and upt.frienduserid=udt.user_id
and status=1
);



Select distinct udt.*,FanCount,PlaymateCount,GameId,
Start_Date,
EventId
from userplaymates udt
left join userPlaymateCount upt
on upt.user_id=udt.user_id
left join userFanCount ufc
on ufc.user_id=udt.user_id
left join userActivity uat
on uat.user_id=udt.user_id;

End