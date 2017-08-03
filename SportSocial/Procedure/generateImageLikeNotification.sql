Delimiter ;;
Drop procedure if exists generateImageLikeNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateImageLikeNotification`(IN `IImageid` INT,IN `Userid` INT)
    NO SQL
BEGIN

set @image_id=IImageid;
set @likeuserid=Userid;



set @userid=(Select AssociatedId from UserImages_tbl where imageid=@image_id limit 1);



set @counts=(Select count(*) from ImageLike_tbl where imageid=@image_id limit 1);

set @username=(Select User_Name from User_tbl where user_id=@likeuserid limit 1);

set @token=(Select Token from UserToken_tbl utt where utt.userid=@userid limit 1);

set @profilephoto=(Select Profile_Photo_Path from User_tbl where user_id=@likeuserid limit 1);

Set @user_id=@userid;
set @Updatestab_name=CONCAT("User",@user_id,"_Updates");


SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (1038) and relatedobjectid in (",@image_id,")");
prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;


Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(@image_id,",",@likeuserid,",'",(current_timestamp()),"',",0,",",@counts,",",0,",",0,",",1038,")");
set @t3= CONCAT(@t1,@t2);

prepare insertnotif from @t3;
Execute insertnotif;
deallocate prepare insertnotif;




Select @likeuserid as userid,0 as gameid,1039 as Activityid,@username as user_name,
"Like Image" as activity_name,0 as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,
0 as IsViewed,0 as IsOpened,@profilephoto as profile_image,1001 as Updateid,@token as token,
0 as frienduser,
"" as friendusername;
End