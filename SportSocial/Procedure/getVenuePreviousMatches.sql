Delimiter ;;
Drop procedure if exists getVenuePreviousMatches;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getVenuePreviousMatches`(IN `IVenueId` INT, IN `timestamp` BIGINT)
BEGIN

set @currenttime=from_unixtime(timestamp/1000);

set @currenttime=(Select AddTime(@currenttime,'5:30:00'));

Drop temporary table if exists EventData_tbl;
Create temporary table EventData_tbl
Select Eventid,ut.User_id,
GameId,
Event_Image,
User_Name,
Unix_Timestamp(Start_Date) as StartDate
from Event_tbl evt
inner join User_tbl ut
on evt.user_id=ut.user_id 
where Start_Date<@currenttime
and Venue_Id=IVenueId;



Select edt.eventid,user_id,gameid,Event_Image,User_Name,StartDate, count(*) as Watchcount
from EventWatch_tbl ewt
inner join EventData_tbl edt
on ewt.eventid=edt.eventid
group by eventid,user_id,gameid,Event_Image,User_Name,StartDate;


End