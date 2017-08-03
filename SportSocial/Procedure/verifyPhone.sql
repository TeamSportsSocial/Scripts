Delimiter ;;
Drop procedure if exists verifyPhone	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `verifyPhone`(IN `IUserid` INT, IN `code` INT)
    NO SQL
Begin 

If exists(Select 1 from UserDetails_tbl where user_id=IUserid and MobileVerificationCode=code and Timediff( CURRENT_TIMESTAMP(),MobCodeInserteddate)<'00:10:00') Then
Begin

Select Iuserid as Userid,"True" as IsVerified;
          
End;
Else
Begin
 
Select Iuserid as Userid,"False" as IsVerified;
          
End;
End if;
 

End