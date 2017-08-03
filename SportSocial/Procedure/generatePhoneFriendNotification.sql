Delimiter ;;
Drop procedure if exists generatePhoneFriendNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generatePhoneFriendNotification`(IN `Userid` INT)
    NO SQL
BEGIN

set @phone=(Select Mobile from User_tbl where user_id=Userid);
set @userid=Userid;

Drop temporary table if exists userslist;
CREATE temporary TABLE userslist
Select distinct User_Id,token,User_Name
from UserContactDetails_tbl ucd
inner join User_tbl ut on
ut.user_id=ucd.userid
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where ucd.Contact=@phone
limit 50000;


set @Updatestab_name=CONCAT("User",@userid,"_Updates");
SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (1040)");

prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;


Drop temporary table if exists userslistwithtokentemp;
CREATE temporary TABLE userslistwithtokentemp	
Select * from userslist;


While exists(Select 1=1 from userslistwithtokentemp)DO

Set @user_id=(Select User_Id from userslistwithtokentemp limit 1);
set @Updatestab_name=CONCAT("User",@user_id,"_Updates");



Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(0,",",@userid,",'",(current_timestamp()),"',",0,",",0,",",0,",",0,",",1039,")");
set @t3= CONCAT(@t1,@t2);

prepare insertnotif from @t3;
Execute insertnotif;
deallocate prepare insertnotif;


Delete uid
from userslistwithtokentemp uid where User_Id=@user_id;

ENd while;


Select user_id as userid,0 as gameid,1039 as Activityid,User_Name as user_name,
"Phone Friend Notification" as activity_name,0 as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,
0 as IsViewed,0 as IsOpened,"" as profile_image,1001 as Updateid,token as token,
0 as frienduser,
"" as friendusername
from userslist
limit 50000;
End