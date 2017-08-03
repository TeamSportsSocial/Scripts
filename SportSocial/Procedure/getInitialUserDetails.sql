Delimiter ;;
Drop procedure if exists getInitialUserDetails;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getInitialUserDetails`(IN `IUserid` INT, IN `ProfileId` INT, IN `IUserName` VARCHAR(5000))
    NO SQL
Begin 

If not(IsNull(IUserName) or IUserName like '' or IUserName like 'undefined') then
Begin
set IUserid=(Select User_Id from User_tbl where user_name like IUserName limit 1) ;
End;
End if;

set @eventcount=(select count(*) from Event_Joinees_tbl where userid=IUserId);

set @commentcount=(select count(*) from FeedComment_tbl where userid=IUserId);

set @promotecount=(select count(*) from FeedPromote_tbl where userid=IUserId);

set @watchcount=(select count(*) from EventWatch_tbl where userid=IUserId);

set @totalActivities=@eventcount+@commentcount+@promotecount+@watchcount;

set @playMateCount=(SELECT count(distinct userid,frienduserid) FROM `User_Playmates_tbl` WHERE (userid=IUserId or frienduserid=IUserId) and status=1);

set @fansCount=(SELECT COUNT( distinct frienduserid ) FROM User_Playmates_tbl WHERE userid =IUserId and status=0);

set @IsPlaymate=(SELECT status FROM User_Playmates_tbl WHERE userid=ProfileId and FriendUserId=IUserId limit 1);

set @imageid1=(Select Imageid from User_tbl ut inner join UserImages_tbl uit on ut.Profile_Photo_Path=uit.Path where User_Id=IUserId limit 1);

set @imageid2=(Select Imageid from User_tbl ut inner join UserImages_tbl uit on ut.Cover_Pic_Path=uit.Path where User_Id=IUserId limit 1);

 set @imageid1commentcount=(Select count(*) as commentcount from ImageComment_tbl where Imageid=@imageid1);
 
  set @imageid1likecount=(Select count(*) as commentcount from ImageLike_tbl where Imageid=@imageid1);
 
  set @imageid2commentcount=(Select count(*) as commentcount from ImageComment_tbl where Imageid=@imageid2);
 
  set @imageid2likecount=(Select count(*) as commentcount from ImageLike_tbl where Imageid=@imageid2);
 
 
Drop temporary table if exists userImages;
CREATE temporary TABLE userImages
Select @imageid1 as imageId,Profile_Photo_Path as profile_photo,@imageid1likecount as likecount,@imageid1commentcount as commentcount
from User_tbl 
where User_Id=IUserId;

Insert into userImages
Select @imageid2 as imageId,Cover_Pic_Path as cover_photo,@imageid2likecount as likecount,@imageid2commentcount as commentcount
from User_tbl 
where User_Id=IUserId;




If (@IsPlaymate is null) then
Begin
if exists(SELECT 1 FROM User_Playmates_tbl WHERE userid =IUserId and FriendUserId=ProfileId limit 1) then
Begin
set @IsPlaymate=2;
End;
Else
set @IsPlaymate=null;
Begin
End;
End if;
End;
End if;


SELECT ut.User_id,
Concat(FirstName,' ',LastName) as User_Name,
FirstName,
LastName,
UniqueName,
CONCAT(UCASE(MID(Gender,1,1)),MID(Gender,2)) AS Gender,
Mobile as Phone,
ut.DateofBirth as DateofBirth,
case when City=''then null else City end as currentuserlocation,
profile_photo_path as profile_image,
Cover_Pic_Path as coverpic,
TypeofInstn,
InstnName,
EmailId,
PreviousInstnType,
PreviousInstnName,
@totalActivities as TotalActivites,
@watchcount as WatchCount,
@fansCount as Fancount,
@playMateCount/2 as PlayMateCount,
@IsPlaymate as IsPlaymate,
IsEmailVerified,
IsPhoneVerified,
HomeCity as City,
Academy
from User_tbl ut
left join UserDetails_tbl udt
on ut.user_id=udt.user_id
where ut.user_id=IUserId;

SELECT distinct gt.gamename,gt.gameid,uit.status 
FROM Game_tbl gt
inner join UserInterest_tbl uit 
on gt.gameid=uit.gameid 
and user_id=IUserId;

 
Select distinct uid.UserId,gqt.Gameid,uid.QuestionId,uid.Answer
from UserInterestDetails_tbl uid
inner join GameQuestions_tbl gqt
on uid.questionid=gqt.questionid
where uid.userid=IUserId;


Select * from userImages;



End