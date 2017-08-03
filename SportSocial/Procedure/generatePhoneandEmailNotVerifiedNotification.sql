Delimiter ;;
Drop procedure if exists generatePhoneandEmailNotVerifiedNotification;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generatePhoneandEmailNotVerifiedNotification`()
    NO SQL
BEGIN



Drop temporary table if exists userslist;
CREATE temporary TABLE userslist
Select distinct ut.User_Id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1041 as Activityid,'Email_Not_Verified' as ActivityName
from UserDetails_tbl udt
inner join User_tbl ut on
ut.user_id=udt.user_id
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where udt.IsEmailVerified<>1
limit 50000;

Insert into userslist
Select distinct ut.User_Id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1042 as Activityid,'Incomplete_Info' as ActivityName
from UserDetails_tbl udt
inner join User_tbl ut on
ut.user_id=udt.user_id
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where udt.InstnName is null or PreviousInstnName is null
limit 50000;


Insert into userslist
Select distinct ut.User_Id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1040 as Activityid,'Phone_Not_Verified' as ActivityName
from UserDetails_tbl udt
inner join User_tbl ut on
ut.user_id=udt.user_id
inner join UserToken_tbl utt
on ut.user_id=utt.userid
where udt.IsPhoneVerified<>1
limit 50000;

Insert into userslist
Select distinct ut.User_Id,token,Concat(FirstName,Concat(' ',LastName)) as User_Name,1043 as Activityid,'Incomplete_Details' as ActivityName
from User_tbl ut
inner join UserToken_tbl utt
on ut.user_id=utt.userid 
where not exists
(
Select 1 from UserInterestDetails_tbl udi
where udi.UserId=ut.User_id
);


Drop temporary table if exists userslistwithtokentemp;
CREATE temporary TABLE userslistwithtokentemp	
Select * from userslist;


While exists(Select 1=1 from userslistwithtokentemp)DO

Set @user_id=(Select User_Id from userslistwithtokentemp limit 1);
set @Updatestab_name=CONCAT("User",@user_id,"_Updates");
set @activityid= (Select Activityid from userslistwithtokentemp where User_Id=@user_id  limit 1);

set @Updatestab_name=CONCAT("User",@user_id,"_Updates");
SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (",@activityid,")");

prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;

Set @t1= CONCAT("Insert into ",@Updatestab_name,"(relatedobjectid,userid,Createddate,Gameid,No_of_players,IsViewed,IsOpened,activityid) values(");
Set @t2=CONCAT(0,",",@user_id,",'",(current_timestamp()),"',",0,",",0,",",0,",",0,",",@activityid,")");
set @t3= CONCAT(@t1,@t2);



prepare insertnotif from @t3;
Execute insertnotif;
deallocate prepare insertnotif;


Delete uid
from userslistwithtokentemp uid where User_Id=@user_id and Activityid=@activityid;

ENd while;


Select user_id as userid,0 as gameid,Activityid,User_Name as user_name,
ActivityName as activity_name,0 as relatedobjectid,0 as No_of_players,
unix_timestamp(Current_timestamp()) as InsertedDate,
0 as IsViewed,0 as IsOpened,"" as profile_image,1001 as Updateid,token as token,
0 as frienduser,
"" as friendusername
from userslist
limit 50000;
End