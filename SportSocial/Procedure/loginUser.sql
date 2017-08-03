Delimiter ;;
Drop procedure if exists loginUser;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `loginUser`(IN `IUsername` VARCHAR(1024), IN `IPassword` VARCHAR(1024))
    NO SQL
Begin

if exists(Select 1 from User_tbl where UniqueName=IUsername) then
Begin
if exists(Select 1 from User_tbl where UniqueName=IUsername and password=IPassword) then
Begin

Select "True" as IsLoggedIn,"No Error" as ErrorMessage, User_id as Userid
from User_tbl where UniqueName=IUsername and password=IPassword limit 1;

End;
Else
Begin
Select "False" as IsLoggedIn,"Incorrect Password" as ErrorMessage;

End;
End if;

End;
Else
Begin

Select "False" as IsLoggedIn,"Incorrect UserName" as ErrorMessage;

End;

End if;


End