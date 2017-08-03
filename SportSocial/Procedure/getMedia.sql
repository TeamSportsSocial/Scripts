Delimiter ;;
Drop procedure if exists getMedia;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getMedia`(IN `IUserId` INT, IN `ProfileId` INT, IN `limiter` INT, IN `skip` INT)
BEGIN


set @limiter=limiter;
set @skip=skip;


drop temporary table if exists eventResults;
create temporary table eventResults
Select EventId, 1002 as ActivityType
from Event_Joinees_tbl 
where UserId=IUserId;

Insert into eventResults
Select EventId,1009 as ActivityType	
from EventWatch_tbl
where UserId=IUserId;

Insert into eventResults
Select EventId,1005 as ActivityType	
from FeedComment_tbl 
where UserId=IUserId;

Insert into eventResults
Select EventId,1004 as ActivityType	
from FeedPromote_tbl 
where UserId=IUserId;


Drop temporary table if exists imageCount;
Create temporary table imageCount
Select Imageid, count(*) as commentcount
from ImageComment_tbl
group by Imageid;

Drop temporary table if exists imagelikedCount;
Create temporary table imagelikedCount
Select Imageid, count(*) as likecount
from ImageLike_tbl
where Liked=1
group by Imageid;

Drop temporary table if exists imageResult;
Create temporary table imageResult 
Select distinct et.ImageId,text,AssociatedId as Id,Path,Type,ActivityType,
commentcount,likecount,liked as IsLiked,et.UserId
from UserImages_tbl et
inner join eventResults evr
on et.AssociatedId=evr.EventId
left join imageCount ic
on ic.Imageid=et.Imageid
left join imagelikedCount il
on il.Imageid=et.Imageid
left join ImageLike_tbl ilt
on ilt.Imageid=et.imageid
and ilt.Userid=IUserId;

Insert into imageResult
Select distinct et.ImageId,text,AssociatedId as Id,Path,Type,0 as ActivityType,
commentcount,likecount,liked as IsLiked ,et.UserId
from UserImages_tbl et
left join imageCount ic
on ic.Imageid=et.Imageid
left join imagelikedCount il
on il.Imageid=et.Imageid
left join ImageLike_tbl ilt
on ilt.Imageid=et.imageid
and ilt.Userid=IUserId
where et.AssociatedId=IUserId
and Type=1;


Insert into imageResult
Select distinct uit.ImageId,text,
vdt.Userid as Id,
Path,Type,
1 as ActivityType
,commentcount
,likecount
,liked as IsLiked 
,uit.UserId
from VenueDetails_tbl vdt
inner join UserImages_tbl uit
on vdt.VenueId=uit.AssociatedId
left join imageCount ic
on ic.Imageid=uit.Imageid
left join imagelikedCount il
on il.Imageid=uit.Imageid
left join ImageLike_tbl ilt
on ilt.Imageid=uit.imageid
and ilt.Userid=IUserId
where vdt.Userid=IUserId;


set @t1=Concat("
Select distinct ser.*,ut.User_Name,ut.Profile_photo_path as profile_photo,userid
               from imageResult ser
inner join User_tbl ut
on ser.id=ut.user_id limit ");
set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;


End