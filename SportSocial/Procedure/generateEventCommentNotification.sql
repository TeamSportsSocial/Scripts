Delimiter ;;
Drop procedure if exists generateEventCommentNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generateEventCommentNotification`(IN `Iuserid` INT, IN `Ieventid` INT, IN `Iactivityid` INT, IN `IComment` VARCHAR(5000) CHARSET latin1)
Begin
Set @Iuserid=Iuserid;
set @Ieventid=Ieventid;
set @Iactivityid=Iactivityid;
set @dat=CURDATE();
set @status=1;

set @str=IComment;
set @newstr= SPLIT_STRING(@str,'@',-1);

set @str=REPLACE(@newstr,' ',';');

set @uniquename=SPLIT_STRING(@str,';',1);

set @taggeduserid=(Select User_Id from User_tbl where UniqueName like @uniquename limit 1);

set @gameid=(Select Gameid from Event_tbl where eventid=@Ieventid);




Drop temporary table if exists NotificationUseridsss;
CREATE temporary TABLE NotificationUseridsss
Select User_id as userid,token,1052 as activityid,'Tagged in Comment' as ActivityName
from User_tbl ut
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where user_id=@taggeduserid;

drop temporary table if exists NotificationUseridsssdummy;
Create temporary table NotificationUseridsssdummy
Select * from NotificationUseridsss;


Insert into NotificationUseridsss
Select ewt.userid,token,1002 as activityid,'Joined Comment' as ActivityName
 from Event_Joinees_tbl ewt
inner join UserToken_tbl utt
on utt.userid=ewt.userid
where eventid=@Ieventid
and ewt.userid<>@Iuserid
and not exists
(
Select 1 from NotificationUseridsssdummy nul
where nul.userid=ewt.userid
);

drop temporary table if exists NotificationUseridsssdummy;
Create temporary table NotificationUseridsssdummy
Select * from NotificationUseridsss;


Insert into NotificationUseridsss
Select distinct ewt.userid,token,1009 as activityid,'Watched Comment' as ActivityName
from EventWatch_tbl ewt
inner join UserToken_tbl utt
on utt.userid=ewt.userid
where Eventid=@Ieventid
and ewt.userid<>@Iuserid
and not exists
(
Select 1 from NotificationUseridsssdummy nul
where nul.userid=ewt.userid
);

drop temporary table if exists NotificationUseridsssdummy;
Create temporary table NotificationUseridsssdummy
Select * from NotificationUseridsss;

Insert into NotificationUseridsss
Select distinct fct.userid,token,1005 as activityid,'Commented Comment' as ActivityName
from FeedComment_tbl fct
inner join UserToken_tbl utt
on fct.userid=utt.userid
where Eventid=@Ieventid
and fct.userid<>@Iuserid
and not exists
(
Select 1 from NotificationUseridsssdummy nul
where nul.userid=fct.userid
);


drop temporary table if exists NotificationUseridsssdummy;
Create temporary table NotificationUseridsssdummy
Select * from NotificationUseridsss;

set @gameid=(Select evt.gameid from Event_tbl evt inner join Game_tbl gt on evt.gameid=gt.gameid where evt.eventid=Ieventid);
set @commentcount=(Select count(*) from FeedComment_tbl where eventid=@Ieventid);
if(@promotecount>0)then
Begin
Set @commentcount=@commentcount-1;
End;
End if;
Set @commentcount=coalesce(@commentcount,0);





While exists(Select 1=1 from NotificationUseridsss)DO

Set @user_id=(Select userid from NotificationUseridsss order by activityid limit 1);

set @Updatestab_name=CONCAT("User",@user_id,"_Updates");

set @notificationactivityid=(Select activityid from NotificationUseridsss where userid=@user_id order by activityid limit 1);

set @notificationactivityid=case when @notificationactivityid=1009 then 1013 else case when @notificationactivityid=1005 then 1014 else case when @notificationactivityid=1052 then 1052 else 1005 end end end ;

SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where relatedobjectid=",@Ieventid," " ,"and activityid in (1013,1005,1014,1052)");
Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(@Ieventid,",",@Iuserid,",'",(current_timestamp()),"',",@gameid,",",@commentcount,",",0,",",0,",",@notificationactivityid,")");
set @t3= CONCAT(@t1,@t2);



prepare deletefeed from @t4;
Execute deletefeed;
deallocate prepare deletefeed;

prepare insertfeed from @t3;
Execute insertfeed;
deallocate prepare insertfeed;

DELETE uid FROM NotificationUseridsss uid 
WHERE
    userid = @user_id;
end while;


Set @gameid=(Select gameid from Event_tbl where eventid=Ieventid);
set @gamename=(Select gamename from Game_tbl where gameid=@gameid);
set @user_name=(Select User_Name from User_tbl where user_id=Iuserid);
set @profile_photo_path=(Select profile_photo_path from User_tbl where user_id=Iuserid);

Select userid,@gameid as gameid,Activityid,@user_name as user_name,
ActivityName as activity_name,0 as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,
0 as IsViewed,0 as IsOpened,@profile_photo_path as profile_image,1001 as Updateid,token as token,
0 as frienduser,
"" as friendusername
from NotificationUseridsssdummy
limit 50000;

End