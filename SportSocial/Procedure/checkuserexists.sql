Delimiter ;;
Drop procedure if exists checkUserExists;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkUserExists`(IN `str` VARCHAR(2000))
    NO SQL
Begin
if exists(Select 1 from User_tbl ut  where EmailId like str) then
Begin
Select 'success' as status,Emailid,Mobile as phone,User_id as userId
from User_tbl ut  where EmailId like str;
End;
elseif exists(Select 1 from User_tbl ut  where Mobile like str) then
Begin
Select 'success' as status,Emailid,Mobile as phone,User_id as userId
from User_tbl ut  where Mobile like str;
End;
elseif exists(Select 1 from User_tbl ut  where Uniquename like str) then
Begin
Select 'success' as status,Emailid,Mobile as phone,User_id as userId
from User_tbl ut  where Uniquename like str;
End;
else
Begin
Select 'Invalid Data' as status;
End;
End if;

End