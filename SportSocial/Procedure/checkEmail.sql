Delimiter ;;
Drop procedure if exists checkEmail;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkEmail`(IN `email` VARCHAR(2000))
    NO SQL
Begin
if exists(Select 1 from User_tbl ut  where EmailId like email) then
Begin
Select 'True' as Status;
End;
else
Begin
Select 'False' as Status;
End;
End if;

End