Delimiter ;;
Drop procedure if exists ComentImage;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ComentImage`(IN `IUserId` INT, IN `IComment` TEXT, IN `IImageid` INT)
    NO SQL
Begin

Insert into ImageComment_tbl(ImageId,Comment,UserId)
values(IImageid,IComment,IUserId);

Select ImageId,Comment,UserId,CommentId,User_Name,
Profile_Photo_Path as profile_pic
from ImageComment_tbl ict
inner join User_tbl utt
on ict.Userid=utt.user_id
where ict.imageid=IImageid;

End