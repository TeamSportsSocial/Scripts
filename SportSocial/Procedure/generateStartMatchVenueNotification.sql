Delimiter ;;
Drop procedure if exists generateStartMatchVenueNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateStartMatchVenueNotification`(IN `IEventId` INT, IN `Userid` INT)
    NO SQL
BEGIN

set @eventid=IEventId;
set @userid=Userid;





set @venueid=(Select Venue_Id from Event_tbl where EventId=@eventid limit 1);
set @venueName=(Select Venue_Name from VenueDetails_tbl where Venueid=@venueid limit 1);
set @gameid =(Select GameId from Event_tbl where EventId=@eventid limit 1);
set @gamename =(Select GameName from Game_tbl where GameId=@gameid limit 1);

Drop temporary table if exists userslist;
CREATE temporary TABLE userslist
Select distinct ut.User_Id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1045 as Activityid,'Match Start at Favorite Venue' as ActivityName
from FavouriteVenue_tbl fvt
inner join User_tbl ut on
ut.user_id=fvt.userid
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where fvt.VenueId=@venueid and
fvt.userid<>@userid
limit 50000;




Drop temporary table if exists userslistwithtokentemp;
CREATE temporary TABLE userslistwithtokentemp	
Select * from userslist;



While exists(Select 1=1 from userslistwithtokentemp)DO

Set @user_id=(Select User_Id from userslistwithtokentemp limit 1);
set @Updatestab_name=CONCAT("User",@user_id,"_Updates");
set @activityid= (Select Activityid from userslistwithtokentemp where User_Id=@user_id  limit 1);

SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (",@activityid,") and relatedobjectid in (",@eventid,")");


prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;


Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(@eventid,",",@venueid,",'",(current_timestamp()),"',",@gameid,",",0,",",0,",",0,",",@activityid,")");
set @t3= CONCAT(@t1,@t2);

prepare insertnotif from @t3;
Execute insertnotif;
deallocate prepare insertnotif;




Delete uid
from userslistwithtokentemp uid where User_Id=@user_id and Activityid=@activityid;

ENd while;




Select user_id as userid,@gameid as gameid,@gamename as GameName,Activityid,User_Name as user_name,
ActivityName as activity_name,@eventid as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,@venueName as VenueName,
0 as IsViewed,0 as IsOpened,"" as profile_image,1001 as Updateid,token as token,
0 as frienduser,
"" as friendusername
from userslist
limit 50000;
End