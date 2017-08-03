Delimiter ;;
Drop procedure if exists verifyEmail	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `verifyEmail`(IN `code` INT)
    NO SQL
Begin 

If exists(Select 1 from UserDetails_tbl where Emailcode=code and Timediff(CURRENT_TIMESTAMP(),EmailCodeInserteddate)<'00:10:00') Then
Begin

Update UserDetails_tbl
set IsEmailVerified=1
where Emailcode=code and
Timediff(CURRENT_TIMESTAMP(),EmailCodeInserteddate)<'00:10:00';
          
Select Emailid,"True" as IsVerified
from UserDetails_tbl udt
inner join User_tbl utt
on udt.user_id=utt.user_id
where Emailcode=code;
          
End;
Else
Begin
 
Select "False" as IsVerified;
          
End;
End if;
 

End