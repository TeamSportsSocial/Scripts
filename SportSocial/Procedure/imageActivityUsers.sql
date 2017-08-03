Delimiter ;;
Drop procedure if exists imageActivityUsers;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `imageActivityUsers`(IN `IImageId` INT, IN `IUserId` INT, IN `IActivityId` INT)
    NO SQL
Begin
if(IActivityId=1037)then
Begin

Select Userid,User_Name,Profile_Photo_path as Profile_Photo
from ImageLike_tbl ilk
inner join User_tbl ut
on ilk.userid=ut.user_id
where Imageid=IImageId;

End;
Else
Begin

Select Userid,User_Name,Profile_Photo_path as Profile_Photo
from ImageComment_tbl ilk
inner join User_tbl ut
on ilk.userid=ut.user_id
where Imageid=IImageId;

End;

End if;



ENd