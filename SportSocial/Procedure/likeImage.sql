Delimiter ;;
Drop procedure if exists likeImage;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `likeImage`(IN `IImageId` INT, IN `IUserId` INT, IN `IsLiked` INT)
    NO SQL
Begin
If (IsLiked=1) then
Begin
If not exists(Select 1 from ImageLike_tbl where ImageId=IImageId and UserId=IUserId) then
Begin
Insert into ImageLike_tbl(ImageId,UserId,Liked)
values(IImageId,IUserId,1);

End;

Else
Begin

Update ImageLike_tbl
set Liked=1
where 
ImageId=IImageId and UserId=IUserId;

End;
End if;
End;
Else
Begin

Delete from ImageLike_tbl  where ImageId=IImageId and UserId=IUserId;

Set @user_id=(Select AssociatedId from UserImages_tbl where imageid=IImageId limit 1);

set @Updatestab_name=CONCAT("User",@user_id,"_Updates");


SET @t4=CONCAT("Delete ft from ",@Updatestab_name," "," ft where  activityid in (1038) and userid=",IUserId," and relatedobjectid in (",IImageId,")");
prepare deletenotif from @t4;
Execute deletenotif;
deallocate prepare deletenotif;


End;
End if;

Select count(*) as LikeCount from ImageLike_tbl where ImageId=IImageId;

End