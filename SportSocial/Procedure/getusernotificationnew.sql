Delimiter ;;
Drop procedure if exists getusernotificationnew;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getusernotificationnew`(IN `userid` INT, IN `limiter` INT, IN `skip` INT, IN `timestamp` BIGINT)
BEGIN
Set @userid=(Select userid);
set @limiter=limiter;
set @skip=skip;

set @currenttime=from_unixtime(timestamp/1000);

set @Updatestab_name=CONCAT("User",@userid,"_Updates") COLLATE utf8_general_ci;

set @tableexist=(SELECT count(*) 
FROM information_schema.tables
WHERE table_schema = 'SportSocial'
    AND table_name like @Updatestab_name);

if(@tableexist<>0)then
Begin
drop temporary table if exists userupdatestemp_tbl;
Set @t1=Concat("Create temporary table userupdatestemp_tbl
Select * from ",@Updatestab_name," ut
               order by CreatedDate desc
               limit ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);


prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;


drop temporary table if exists userupdates_tbl;
Create temporary table userupdates_tbl
(
Updateid int,
user_name varchar(200),
userid int,
gameid int,
gamename Text,
activity_name varchar(500),
relatedobjectid int,
No_of_players int,
Activityid int,
InsertedDate long,
IsViewed int,
IsOpened int,
profile_image Text,
frienduserid int,
friendusername varchar(500)
);


Insert into userupdates_tbl
Select UpdateId,case when act.activity_id=1023 then et.SS_Username else et.User_Name end,ut.userid,
case when gt.gameid is null then 0 else gt.gameid end as gameid ,
Case when gt.gamename is null then '' else gt.gamename end as gamename,
               act.activity_name,relatedobjectid,
               case when  No_of_players is null then 0 else case when Activityid in (1002,1028,1005) then No_of_players-1 else No_of_players end end as No_of_players,
               Activityid,Unix_Timestamp(CreatedDate) as InsertedDate,
               IsViewed,IsOpened,et.profile_photo_path as profile_image,
               ut1.user_id,
               ut1.user_name 
               from userupdatestemp_tbl ut left join User_tbl et
               on et.user_id=ut.userid
               left join User_tbl ut1
               on ut1.user_id=ut.relatedobjectid
               inner join Activity_tbl act
               on act.activity_id=ut.activityid
               left join Game_tbl gt
               on gt.gameid=ut.gameid
               where ut.activityid not in (1037,1006,1008,1045)
               order by CreatedDate desc;
               
               
Insert into userupdates_tbl
Select UpdateId,"",0, 0  as gameid ,
ntt.text as gamename,
               "InsertNotification",0 as relatedobjectid,
                0  as No_of_players,
               1037,Unix_Timestamp(CreatedDate) as InsertedDate,
               IsViewed,IsOpened,"http://prod.sportsocial.in/defaultimages/fnal_app_icon.png" as profile_image,
               0,
               "http://prod.sportsocial.in/defaultimages/fnal_app_icon.png" 
               from userupdatestemp_tbl ut inner join NotificationText_tbl ntt
               on ntt.id=ut.gameid
               where ut.activityid=1037
               order by CreatedDate desc;


Insert into userupdates_tbl
Select UpdateId,case when act.activity_id=1023 then et.SS_Username else et.User_Name end,ut.userid,
case when gt.gameid is null then 0 else gt.gameid end as gameid ,
Case when gt.gamename is null then '' else gt.gamename end as gamename,
               act.activity_name,relatedobjectid,
               case when  No_of_players is null then 0 else case when Activityid in (1002,1028,1005) then No_of_players-1 else No_of_players end end as No_of_players,
               Activityid,Unix_Timestamp(CreatedDate) as InsertedDate,
               IsViewed,IsOpened,et.profile_photo_path as profile_image,
               vdt.VenueId,
               vdt.Venue_Name 
               from userupdatestemp_tbl ut left join User_tbl et
               on et.user_id=ut.userid
               inner join Event_tbl evt
               on evt.EventId=ut.relatedobjectid
               inner join VenueDetails_tbl vdt
               on vdt.Venueid=evt.venue_id
               inner join Activity_tbl act
               on act.activity_id=ut.activityid
               left join Game_tbl gt
               on gt.gameid=ut.gameid
               where ut.activityid in (1045)
               order by CreatedDate desc;




Select * from userupdates_tbl
order by InsertedDate desc;

Select min(UpdateId) as minUpdateid,@Updatestab_name as tablename from userupdates_tbl where IsViewed=0;
End;
End if;

End