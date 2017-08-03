Delimiter ;;
Drop procedure if exists GetMatchInfoNew;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMatchInfoNew`(IN `Event_Id` INT, IN `IUserid` INT)
BEGIN

set @eventjoinee=(Select count(*)
from Event_Joinees_tbl
where eventid=Event_Id);


Set @PromoteCount=(Select count(*) as PromoteCount
from FeedPromote_tbl fpt
where fpt.eventid=Event_Id);


Set @Commentcount=(Select count(*) as Commentcount
from FeedComment_tbl fct
where fct.eventid=Event_Id);


Set @WatchCount=(Select count(*) as WatchCount
from EventWatch_tbl fct
where fct.eventid=Event_Id);

set @startuserid=(Select User_Id from Event_tbl where eventid=Event_Id);


set @latitude=(Select latitude from User_tbl where user_id=IUserid limit 1);
set @longitude=(Select longitude from User_tbl where user_id=IUserid limit 1);


Select distinct et.eventid,et.User_id,user_name,et.latitude,et.longitude,gt.gamename,
Is_Public,event_image,
case when @PromoteCount is null then 0 else @PromoteCount end as PromoteCount,
case when @Commentcount is null then 0 else @CommentCount end as CommentCount,
case when @WatchCount is null then 0 else @WatchCount end as WatchCount,
case when ejt.eventid is null then false else true end as IsPlaying,
case when ewt.eventid is null then false else true end as IsWatching,
@eventjoinee as EventJoineeCount,
@eventjoinee as totalplaymate,
UNix_Timestamp(start_date) as StartTime,
Venue_Name,
EventText,
RestrictionCount as MaxPlaymate,
et.gameid,
@latitude as userlatitude,
@longitude as userlongitude,
UNix_Timestamp(CreationDate) as CreationDate
from Event_tbl et
inner join User_tbl ut
on et.user_id=ut.user_id
inner join Game_tbl gt
on gt.gameid=et.gameid
left join VenueDetails_tbl vt
on vt.venueid=et.venue_id
left join Event_Joinees_tbl ejt
on ejt.eventid=et.eventid
and ejt.userid=IUserid
left join EventWatch_tbl ewt
on ewt.eventid=et.eventid
and ewt.userid=IUserid
where et.eventid=Event_Id;


Select User_id as UserId,user_name as UserName,FirstName,LastName
,Profile_Photo_Path as profilephoto
,case when @startuserid=User_id then 0 else 1 end  as IsStarter 
from Event_Joinees_tbl ejt
inner join User_tbl ut
on ejt.userid=ut.user_id
where eventid=Event_Id;

Select ImageId,Path as imagepath,AssociatedId as eventid,Text,User_Name,
Profile_Photo_Path as profile_photo
from UserImages_tbl uit
left join User_tbl ut
on uit.userid=ut.user_id
where type=2 and AssociatedId=Event_Id;




End