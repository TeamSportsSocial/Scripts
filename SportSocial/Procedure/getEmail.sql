Delimiter ;;
Drop procedure if exists getEmail;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getEmail`(IN `str` VARCHAR(2000), IN `num` VARCHAR(2000))
BEGIN
if exists(Select 1 from User_tbl where EmailId like str) then
Begin
set @count=(Select count(*) from User_tbl where EmailId like str);
if(@count>1)then
Begin
Select 'Multiple' as EmailId,0 as UserId,'Multiple' as status;
End;
Else
Begin

set @userid=(Select User_id from User_tbl where EmailId like str);
if exists(Select 1 from UserDetails_tbl where User_Id=@userid) then
Begin
set @timestamp1=(Select current_timestamp());

Update UserDetails_tbl udt
inner join User_tbl ut
on udt.User_Id=ut.User_Id
set EmailCode=num,
EmailCodeInserteddate=current_timestamp()
where EmailId like str;
End;
Else
Begin
Insert into UserDetails_tbl(User_id,Emailcode,EmailCodeInserteddate)
values(@userid,num,current_timestamp());
End ;
End if;


Select EmailId,User_id as UserId,User_Name as username,
Profile_Photo_Path as profilepic,'success' as status
from User_tbl where EmailId like str;



End;
End if;

End;
Else
Begin
Select null as EmailId,0 as UserId,'Not exists' as status;

End;
End if;

End