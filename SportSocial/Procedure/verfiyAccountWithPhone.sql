Delimiter ;;
Drop procedure if exists verfiyAccountWithPhone	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `verfiyAccountWithPhone`(IN `phone` varchar(2000), IN `code` INT)
    NO SQL
BEGIN

if exists(Select 1 from User_tbl where mobile like phone) then
Begin
set @count=(Select count(*) from User_tbl where mobile like phone);
if(@count>1)then
Begin
Select 'Multiple' as phone,0 as UserId;
End;
Else
Begin

set @userid=(Select User_id from User_tbl where mobile like phone);
if exists(Select 1 from UserDetails_tbl where User_Id=@userid) then
Begin
set @timestamp1=(Select current_timestamp());

Update UserDetails_tbl udt
inner join User_tbl ut
on udt.User_Id=ut.User_Id
set MobileVerificationCode=num,
MobCodeInserteddate=current_timestamp()
where mobile like phone;
End;
Else
Begin
Insert into UserDetails_tbl(User_id,MobileVerificationCode,MobCodeInserteddate)
values(@userid,num,current_timestamp());
End ;
End if;


Select mobile as phone,User_id as UserId from User_tbl where mobile like phone;



End;
End if;

End;
Else
Begin
Select null as phone,0 as UserId;

End;
End if;

End