Delimiter ;;
Drop procedure if exists UpdateMatchDetails	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateMatchDetails`(IN `IEventId` INT, IN `Iuser_id` INT, IN `Istart_date` DATETIME, IN `Ievent_image` LONGTEXT, IN `IRestrictionCount` TEXT, IN `IText` LONGTEXT, IN `IImageText` TEXT)
BEGIN



if(Ievent_image='') then
Begin
set Ievent_image=(Select event_image from Event_tbl where eventid= IEventId limit 1);
end;
End if;

if(Istart_date>curdate()) then 
Begin

Update Event_tbl
set 
start_date=Istart_date
where eventid=IEventId;


End;
End if;

if(IRestrictionCount<>'undefined') then 
Begin

Update Event_tbl
set 
RestrictionCount=IRestrictionCount
where eventid=IEventId;


End;
End if;

if(IText<>'undefined') then 
Begin

Update Event_tbl
set 
EventText=IText
where eventid=IEventId;


End;
End if;

if(Ievent_image<>'') then 
Begin

Insert into UserImages_tbl(Path,Text, Type,AssociatedId,UserId)
values(Ievent_image,IImageText,2,IEventId,Iuser_id);

Update Event_tbl
set 
event_image=Ievent_image
where eventid=IEventId;


End;
End if;

End