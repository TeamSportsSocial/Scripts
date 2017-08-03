Delimiter ;;
Drop procedure if exists checkusername;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkusername`(IN `username` VARCHAR(2000))
    NO SQL
Begin
if exists(Select 1 from User_tbl where UniqueName like username) then
Begin
Select 'True' as Status;
End;
else
Begin
Select 'False' as Status;
End;
End if;

End