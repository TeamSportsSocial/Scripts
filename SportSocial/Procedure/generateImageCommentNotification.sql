Delimiter ;;
Drop procedure if exists generateImageCommentNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateImageCommentNotification`(IN `IImageid` INT, IN `Userid` INT,IN `Icomment` varchar(5000))
    NO SQL
BEGIN

set @image_id=IImageid;
set @commentuserid=Userid;

set @str=IComment;
set @newstr= SPLIT_STRING(@str,'@',-1);

set @str=REPLACE(@newstr,' ',';');

set @uniquename=SPLIT_STRING(@str,';',1);

set @taggeduserid=(Select User_Id from User_tbl where UniqueName like @uniquename);

set @counts=(Select count(*) from ImageComment_tbl where imageid=@image_id limit 1);
set @user_name=(Select User_Name from User_tbl where user_id=@commentuserid);

Drop temporary table if exists userslist;
CREATE temporary TABLE userslist
Select distinct ut.User_Id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1049 as Activityid,'Comment on Image' as ActivityName
from ImageComment_tbl ict
inner join User_tbl ut on
ut.user_id=ict.userid
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where ict.imageid=@image_id and
ict.userid not in (@commentuserid,@taggeduserid)
limit 50000;

Insert into userslist
Select User_id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1051 as Activityid,'Tagged on Image' as ActivityName
from User_tbl ut
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where user_id=@taggeduserid;


Drop temporary table if exists userslistwithtokentemp;
CREATE temporary TABLE userslistwithtokentemp	
Select * from userslist;



While exists(Select 1=1 from userslistwithtokentemp)DO

Set @user_id=(Select User_Id from userslistwithtokentemp limit 1);
set @Updatestab_name=CONCAT("User",@user_id,"_Updates");
set @activityid= (Select Activityid from userslistwithtokentemp where User_Id=@user_id  limit 1);

SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (",@activityid,") and relatedobjectid in (",@image_id,")");


prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;


Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(@image_id,",",@commentuserid,",'",(current_timestamp()),"',",0,",",@counts,",",0,",",0,",",@activityid,")");
set @t3= CONCAT(@t1,@t2);

prepare insertnotif from @t3;
Execute insertnotif;
deallocate prepare insertnotif;




Delete uid
from userslistwithtokentemp uid where User_Id=@user_id and Activityid=@activityid;

ENd while;




Select user_id as userid,0 as gameid,Activityid,@user_name as user_name,
ActivityName as activity_name,0 as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,
0 as IsViewed,0 as IsOpened,"" as profile_image,1001 as Updateid,token as token,
0 as frienduser,
"" as friendusername
from userslist
limit 50000;
End