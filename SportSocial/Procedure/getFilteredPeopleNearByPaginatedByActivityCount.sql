Delimiter ;;
Drop procedure if exists getFilteredPeopleNearByPaginatedByActivityCount;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilteredPeopleNearByPaginatedByActivityCount`(IN `usersid` INT, IN `game_id` INT, IN `minAge` INT, IN `maxAge` INT, IN `gender` VARCHAR(100), IN `instn` VARCHAR(100), IN `city` VARCHAR(100), IN `limiter` INT, IN `skip` INT, IN `timestamp` BIGINT)
BEGIN

set @limiter=limiter;
set @skip=skip;
set @gameid=game_id;
set @pg=@skip/15;
set @minage=minAge;
set @maxage=maxAge;
set @gender=gender;
set @city=city;
set @instn=instn;
set @nullstring="searchednothing";

If (IsNull(@minage)) then
Begin
set @minAge=0;
 End;
 End if;
 
 If (IsNull(@maxage) or @maxage=0) then
Begin
set @maxAge=1000;
 End;
 End if;

 If (IsNull(@city) or @city like '') then
Begin
set @city=@nullstring;
 End;
 End if;


 If (IsNull(@instn) or @instn like '') then
Begin
set @instn=@nullstring;
 End;
 End if;


 If (IsNull(@gender) or @gender like '') then
Begin
set @gender=@nullstring;
 End;
 End if;


drop temporary table if exists EventJoined;
Create temporary table EventJoined
Select user_id, count(*) as JoinedCount from User_tbl ut
left join Event_Joinees_tbl ejt
on ut.user_id=ejt.userid
group by user_id;


drop temporary table if exists EventWatched;
Create temporary table EventWatched
Select user_id, count(*) as WatchedCount from User_tbl ut
inner join EventWatch_tbl ejt
on ut.user_id=ejt.userid
group by user_id;


drop temporary table if exists EventPromoted;
Create temporary table EventPromoted
Select user_id, count(*) as PromoteCount from User_tbl ut
inner join FeedPromote_tbl ejt
on ut.user_id=ejt.userid
group by user_id;


drop temporary table if exists EventCommented;
Create temporary table EventCommented
Select user_id, count(*) as CommentCount from User_tbl ut
inner join FeedComment_tbl ejt
on ut.user_id=ejt.userid
group by user_id;


drop temporary table if exists UserActivityCount;
Create temporary table UserActivityCount
Select ejt.user_id,JoinedCount+WatchedCount+PromoteCount+CommentCount as ActivityCount
from User_tbl ut 
left join EventJoined ejt
on ut.user_id=ejt.user_id
left join EventWatched ewt
on ejt.user_id=ut.user_id
left join EventCommented ect
on ect.user_id=ut.user_id
left join EventPromoted ept
on ept.user_id=ut.user_id;

set @currenttime=from_unixtime(timestamp/1000);

set @currenttime=(Select AddTime(@currenttime,'5:30:00'));
set @usersid=usersid;

drop temporary table if exists usernearby;
Create temporary table usernearby
(
user_id int,
user_name varchar(200),
age int,
Profile_Photo_Path varchar(2000),
distance double(10,2),
ActivityCount int
);


set @lat=(Select latitude from User_tbl where user_id=@usersid);

set @lon=(Select longitude from User_tbl where user_id=@usersid);

if(@lat is not null or @lon is not null) then
Begin

set @t1=Concat("Insert into usernearby
SELECT distinct ut.user_id,
  user_name,
  TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS age,
  Profile_Photo_Path,
   ( 3959 * acos( cos( radians(",@lat,") ) * cos( radians( ut.latitude ) ) 
   * cos( radians(ut.longitude) - radians(",@lon,")) + sin(radians(",@lat,")) 
   * sin( radians(ut.latitude)))) AS distance,
  ActivityCount
FROM User_tbl ut
inner join UserActivityCount uac
on ut.user_id=uac.user_id
left join UserDetails_tbl udt
on ut.user_id=udt.user_id
inner join UserInterest_tbl utt
on ut.user_id=utt.user_id
where ",@usersid,"<>ut.user_id and
utt.gameid=",@gameid,"
and not exists
(
    Select 1 from User_Playmates_tbl upt
    where upt.userid=",@usersid,"
    and upt.frienduserid=ut.user_id
    and upt.status=1
    )
                  and ut.inserteddate<'",@currenttime,"'
               and ut.latitude is not null
               and TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) between ",@minage," and ",@maxage,"
                 and ('",@instn,"' like '",@nullstring,"' or udt.InstnName like '",@instn,"')
               and ('",@city ,"' like '",@nullstring,"' or city like '",@city,"')
               and ('",@gender,"' like '",@nullstring,"' or gender like '",@gender,"')
ORDER BY ActivityCount desc limit"," ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare peopelnearby from @t3;
Execute peopelnearby;
deallocate prepare peopelnearby;

set @t2=0;
set @t2=(Select count(*) from usernearby);
if(@t2=0) then
Begin

drop temporary table if exists usernearbytotalcount;
Create temporary table usernearbytotalcount
(
user_id int,
user_name varchar(200),
age int,
Profile_Photo_Path varchar(2000),
distance double(10,2)
);


set @t1=Concat("Insert into usernearbytotalcount
SELECT distinct ut.user_id,
  user_name,
  TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS age,
  Profile_Photo_Path,
   ( 3959 * acos( cos( radians(",@lat,") ) * cos( radians( ut.latitude ) ) 
   * cos( radians(ut.longitude) - radians(",@lon,")) + sin(radians(",@lat,")) 
   * sin( radians(ut.latitude)))) AS distance 
FROM User_tbl ut
inner join UserActivityCount uac
on ut.user_id=uac.user_id
left join UserDetails_tbl udt
on ut.user_id=udt.user_id
inner join UserInterest_tbl utt
on ut.user_id=utt.user_id
where ",@usersid,"<>ut.user_id and
utt.gameid=",@gameid,"
and not exists
(
    Select 1 from User_Playmates_tbl upt
    where upt.userid=",@usersid,"
    and upt.frienduserid=ut.user_id
    and upt.status=1
    )
               and ut.inserteddate<'",@currenttime,"'
               and ut.latitude is not null 
                and TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) between ",@minage," and ",@maxage,"
                     and ('",@instn,"' like '",@nullstring,"' or udt.InstnName like '",@instn,"')
               and ('",@city ,"' like '",@nullstring,"' or city like '",@city,"')
               and ('",@gender,"' like '",@nullstring,"' or gender like '",@gender,"')
               ");


prepare peopelnearby from @t1;
Execute peopelnearby;
deallocate prepare peopelnearby;

set @t3=0;
set @t3=(Select count(*) from usernearbytotalcount);

set @pageno=Ceiling(@t3/15);
set @skipnew=abs((@pageno-@pg-1)*15);

set @t1=Concat("Insert into usernearby
SELECT distinct ut.user_id,
  user_name,
  TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS age,
  Profile_Photo_Path,
   ( 3959 * acos( cos( radians(",@lat,") ) * cos( radians( ut.latitude ) ) 
   * cos( radians(ut.longitude) - radians(",@lon,")) + sin(radians(",@lat,")) 
   * sin( radians(ut.latitude)))) AS distance,
   ActivityCount
FROM User_tbl ut
inner join UserActivityCount uac
on ut.user_id=uac.user_id
left join UserDetails_tbl udt
on ut.user_id=udt.user_id
inner join UserInterest_tbl utt
on ut.user_id=utt.user_id
where ",@usersid,"<>ut.user_id and
utt.gameid=",@gameid,"
and not exists
(
    Select 1 from User_Playmates_tbl upt
    where upt.userid=",@usersid,"
    and upt.frienduserid=ut.user_id
    and upt.status=1
    )
                  and ut.inserteddate<'",@currenttime,"'
               and ut.longitude is null
                and TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) between ",@minage," and ",@maxage,"
                        and ('",@instn,"' like '",@nullstring,"' or udt.InstnName like '",@instn,"')
               and ('",@city ,"' like '",@nullstring,"' or city like '",@city,"')
               and ('",@gender,"' like '",@nullstring,"' or gender like '",@gender,"')
ORDER BY ActivityCount desc limit"," ");

set @t2=Concat(@skipnew,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare peopelnearby from @t3;
Execute peopelnearby;
deallocate prepare peopelnearby;


End;
End if;


drop  temporary table if exists userPlaymateCount;
Create temporary table userPlaymateCount
Select distinct udt.user_id,(count(*)-1)/2 as PlaymateCount
from usernearby udt
left join User_Playmates_tbl upt
on upt.userid=udt.user_id
and status=1
group by udt.user_id;

drop  temporary table if exists userFanCount;
Create temporary table userFanCount
Select distinct udt.user_id,count(*) as FanCount
from usernearby udt
left join User_Playmates_tbl upt
on upt.frienduserid=udt.user_id
and status=0
group by udt.user_id;


drop  temporary table if exists userActivityTemp;
Create temporary table userActivityTemp
Select distinct udt.user_id,min(evt.EventId) as EventId
from usernearby udt
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




drop  temporary table if exists usernearbyfinal;
Create temporary table usernearbyfinal
Select distinct udt.user_id,
udt.user_name,
age,
Profile_Photo_Path,
round(distance*1.609344,1) as distance,
PlaymateCount,
FanCount,
GameId,
UNix_Timestamp(Start_Date) as Start_Date,
EventId,
ActivityCount
from usernearby udt
inner join userPlaymateCount upt
on upt.user_id=udt.user_id
inner join userFanCount ufc
on ufc.user_id=udt.user_id
inner join userActivity uat
on uat.user_id=udt.user_id
where distance is not null 
order by ActivityCount desc;

Insert into usernearbyfinal
Select distinct udt.user_id,
udt.user_name,
age,
Profile_Photo_Path,
round(distance*1.609344,1) as distance,
PlaymateCount,
FanCount,
GameId,
UNix_Timestamp(Start_Date) As Start_Date,
EventId,
ActivityCount
from usernearby udt
inner join userPlaymateCount upt
on upt.user_id=udt.user_id
inner join userFanCount ufc
on ufc.user_id=udt.user_id
inner join userActivity uat
on uat.user_id=udt.user_id
where distance is null 
order by ActivityCount desc;
End;
Else
Begin
set @t1=Concat("Insert into usernearby
SELECT distinct ut.user_id,
  user_name,
  TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) AS age,
  Profile_Photo_Path,
   'NA' AS distance,
ActivityCount
FROM User_tbl ut
inner join UserActivityCount uac
on ut.user_id=uac.user_id
left join UserDetails_tbl udt
on ut.user_id=udt.user_id
inner join UserInterest_tbl utt
on ut.user_id=utt.user_id
where ",@usersid,"<>ut.user_id and
utt.gameid=",@gameid,"
and not exists
(
    Select 1 from User_Playmates_tbl upt
    where upt.userid=",@usersid,"
    and upt.frienduserid=ut.user_id
    and upt.status=1
    )
                   and ut.inserteddate<'",@currenttime,"'
                and TIMESTAMPDIFF(YEAR, ut.DateofBirth, CURDATE()) between ",@minage," and ",@maxage,"
                  and ('",@instn,"' like '",@nullstring,"' or udt.InstnName like '",@instn,"')
               and ('",@city ,"' like '",@nullstring,"' or city like '",@city,"')
               and ('",@gender,"' like '",@nullstring,"' or gender like '",@gender,"')
order by ActivityCount desc limit"," ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare peopelnearby from @t3;
Execute peopelnearby;
deallocate prepare peopelnearby;



drop  temporary table if exists userPlaymateCount;
Create temporary table userPlaymateCount
Select distinct udt.user_id,(count(*)-1)/2 as PlaymateCount
from usernearby udt
left join User_Playmates_tbl upt
on upt.userid=udt.user_id
and status=1;

drop  temporary table if exists userFanCount;
Create temporary table userFanCount
Select distinct udt.user_id,count(*)/2 as FanCount
from usernearby udt
left join User_Playmates_tbl upt
on upt.frienduserid=udt.user_id
and status=0;


drop  temporary table if exists userActivity;
Create temporary table userActivity
Select distinct udt.user_id,GameId,Start_Date,evt.EventId
from usernearby udt
left join Event_Joinees_tbl ejt
on ejt.Userid=udt.user_id
left join Event_tbl evt
on evt.EventId=ejt.EventID
and Start_Date>@currenttime;

drop  temporary table if exists usernearbyfinal;
Create temporary table usernearbyfinal
Select distinct udt.user_id,
udt.user_name,age,Profile_Photo_Path,
'NA' as distance,
PlaymateCount,
FanCount,
GameId,
UNix_Timestamp(Start_Date) as Start_Date,
EventId,
ActivityCount
from usernearby udt
inner join userPlaymateCount upt
on upt.user_id=udt.user_id
inner join userFanCount ufc
on ufc.user_id=udt.user_id
inner join userActivity uat
on uat.user_id=udt.user_id;

End;
End if;

Select * from usernearbyfinal
order by ActivityCount desc;
  END