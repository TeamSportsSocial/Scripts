Delimiter ;;
Drop procedure if exists changePassword;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `changePassword`(IN `str` VARCHAR(2000), IN `Iemailid` VARCHAR(2000))
BEGIN

if exists(Select 1 from User_tbl ut  where EmailId like Iemailid) then
Begin

Update User_tbl
set password=str
where emailid=Iemailid;

Select 'success' as Status;
End;
elseif exists(Select 1 from User_tbl ut  where UniqueName like Iemailid) then
Begin
Update User_tbl
set password=str
where UniqueName=Iemailid;

Select 'success' as Status;
End;
else
Begin
Select 'failure' as Status;
End;
End if;

End