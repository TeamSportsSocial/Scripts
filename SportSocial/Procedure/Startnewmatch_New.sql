Delimiter ;;
Drop procedure if exists Startnewmatch_New	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Startnewmatch_New`(IN `Venue_Name` VARCHAR(2000), IN `Latitude` DOUBLE(10,2), IN `Longitude` DOUBLE(10,2), IN `Iuser_id` INT, IN `start_date` DATETIME, IN `GameId` INT, IN `Is_Public` INT, IN `statusid` INT, IN `event_image` VARCHAR(200), IN `EventText` VARCHAR(2000), IN `RestrictionCount` INT, IN `IVenueId` INT)
BEGIN

set @userid=Iuser_id;
set @event_image=event_image;

if(IVenueId=0) then
Begin
insert into VenueDetails_tbl(Userid,Venue_Name,Latitude,Longitude,Emailid,VenueType) 
Select user_id,Venue_Name,Latitude,Longitude,Emailid,2
from User_tbl where user_id=@userid;


set @venueid=(SELECT LAST_INSERT_ID());
End;
else
Begin

set @venueid=IVenueId;
End ;
End if;


if(event_image='') then
Begin
call FetchImageForGames(GameId,@et);
set event_image=(Select @et);

end;
End if;


insert into Event_tbl(user_id,start_date,venue_id,GameId,Is_Public,status,event_image,Latitude,Longitude,EventText,RestrictionCount)
values(Iuser_id,start_date,@venueid,GameId,Is_Public,statusid,event_image,Latitude,Longitude,EventText,RestrictionCount);

set @eventid=(SELECT LAST_INSERT_ID());

if(@event_image<>'') then
Begin

Insert into UserImages_tbl(Path,Text, Type,AssociatedId,UserId)
values(event_image,'',2,@eventid,Iuser_id);

end;
End if;



Insert into Event_Joinees_tbl(eventid,userid, status,invitee_userid)
values(@eventid,@userid,3,Iuser_id);

Select @eventid as eventid,"True" as IsSuccessfull;
End