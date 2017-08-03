Delimiter ;;
Drop procedure if exists UpdateEmailVerificationCode	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateEmailVerificationCode`(IN `email` VARCHAR(1024), IN `code` INT, IN `IUserId` INT)
    NO SQL
Begin
if exists(Select 1 from UserDetails_tbl where User_Id=IUserId) then
Begin
set @timestamp1=(Select current_timestamp());

Update UserDetails_tbl 
set Emailcode=code,
EmailCodeInserteddate=@timestamp1 
where User_Id=IUserId;
End;
Else
Begin
Insert into UserDetails_tbl(User_id,Emailcode,EmailCodeInserteddate)
values(IUserId,code,current_timestamp());
End ;
End if;

Select User_Name,Profile_Photo_Path as ProfilePic
from User_tbl where user_id=IUserId;

End