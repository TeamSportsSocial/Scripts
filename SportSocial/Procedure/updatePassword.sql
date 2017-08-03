Delimiter ;;
Drop procedure if exists updatePassword	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePassword`(IN `IUserId` INT, IN `oldPassword` VARCHAR(5000), IN `newPassword` VARCHAR(5000))
    NO SQL
Begin
If exists(Select 1 from User_tbl where User_id=IUserId and password=oldPassword) then
Begin
Update User_tbl
set Password=newPassword
where User_id=IUserId
and password=oldPassword;

Select 'success' as status;
End;
Else
Begin
Select 'failure' as status;

End;
End if;


End