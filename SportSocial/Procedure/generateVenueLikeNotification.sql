Delimiter ;;
Drop procedure if exists generateVenueLikeNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateVenueLikeNotification`(IN `IVenueId` INT,IN `Userid` INT)
    NO SQL
BEGIN

set @venueid=IVenueId;
set @likeuserid=Userid;



set @userid=(Select Userid from VenueDetails_tbl where venueid=@venueid limit 1);



set @username=(Select User_Name from User_tbl where user_id=@likeuserid limit 1);

set @token=(Select Token from UserToken_tbl utt where utt.userid=@userid limit 1);

set @profilephoto=(Select Profile_Photo_Path from User_tbl where user_id=@likeuserid limit 1);

Set @user_id=@userid;
set @Updatestab_name=CONCAT("User",@user_id,"_Updates");


SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (1044) and userid in (",@likeuserid,") and relatedobjectid in (",@venueid,")");
prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;


Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(@venueid,",",@likeuserid,",'",(current_timestamp()),"',",0,",",0,",",0,",",0,",",1044,")");
set @t3= CONCAT(@t1,@t2);

prepare insertnotif from @t3;
Execute insertnotif;
deallocate prepare insertnotif;




Select @likeuserid as userid,0 as gameid,1044 as Activityid,@username as user_name,
"Like Venue" as activity_name,0 as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,
0 as IsViewed,0 as IsOpened,@profilephoto as profile_image,1001 as Updateid,@token as token,
0 as frienduser,
"" as friendusername;
End