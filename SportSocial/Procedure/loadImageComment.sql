Delimiter ;;
Drop procedure if exists loadImageComment;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `loadImageComment`(IN `IImageId` INT, IN `IUserId` INT)
    NO SQL
Begin
Select ImageId,Comment,UserId,CommentId,User_Name,
Profile_Photo_Path as profile_pic
from ImageComment_tbl ict
inner join User_tbl utt
on ict.Userid=utt.user_id
where ict.imageid=IImageid;
End