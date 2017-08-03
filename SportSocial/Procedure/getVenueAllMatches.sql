Delimiter ;;
Drop procedure if exists getVenueAllMatches;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getVenueAllMatches`(IN `IVenueId` INT, IN `timestamp` BIGINT,IN `limiter` INT,IN `skip` INT)
BEGIN


set @limiter=limiter;
set @skip=skip;


set @currenttime=from_unixtime(timestamp/1000);

set @currenttime=(Select AddTime(@currenttime,'5:30:00'));

Drop temporary table if exists EventData_tbl;
Create temporary table EventData_tbl
Select Eventid,ut.User_id,
GameId,
Event_Image,
User_Name,
Unix_Timestamp(Start_Date) as StartDate,
1 as IsPrevious
from Event_tbl evt
inner join User_tbl ut
on evt.user_id=ut.user_id 
where Start_Date<@currenttime
and Venue_Id=IVenueId;

Insert into EventData_tbl
Select Eventid,ut.User_id,
GameId,
Event_Image,
User_Name,
Unix_Timestamp(Start_Date) as StartDate,
0 as IsPrevious
from Event_tbl evt
inner join User_tbl ut
on evt.user_id=ut.user_id 
where Start_Date<=@currenttime
and Venue_Id=IVenueId;


set @t1=Concat("
Select distinct edt.eventid,user_id,gameid,Event_Image,User_Name,StartDate, count(*) as Watchcount,IsPrevious
from EventWatch_tbl ewt
inner join EventData_tbl edt
on ewt.eventid=edt.eventid
group by eventid,user_id,gameid,Event_Image,User_Name,StartDate,IsPrevious
order by StartDate desc limit ");
set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;

Select edt.eventid,user_id,gameid,Event_Image,User_Name,StartDate, count(*) as Watchcount,IsPrevious
from EventWatch_tbl ewt
inner join EventData_tbl edt
on ewt.eventid=edt.eventid
group by eventid,user_id,gameid,Event_Image,User_Name,StartDate,IsPrevious
order by StartDate desc;


End