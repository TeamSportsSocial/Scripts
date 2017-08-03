Delimiter ;;
Drop procedure if exists updateBasicDetails	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateBasicDetails`(IN `IUserId` INT, IN `IUserName` VARCHAR(1024), IN `Ipassword` VARCHAR(1024), IN `IPhone` VARCHAR(1024), IN `IEmailId` VARCHAR(1024))
BEGIN
if(IUserName<>'' and IUserName<>'undefined') then
Begin
Update User_tbl
set UniqueName=IUserName
where User_Id=IUserId;
End;
End if;


if(Ipassword<>'' and Ipassword<>'undefined') then
Begin
Update User_tbl
set password=Ipassword
where User_Id=IUserId;
End;
End if;

if(IPhone<>'' and IPhone<>'undefined') then
Begin
Update User_tbl
set Mobile=IPhone
where User_Id=IUserId;
End;
End if;

if(IEmailId<>'' and IEmailId<>'undefined') then
Begin
Update User_tbl
set EmailId=IEmailId
where User_Id=IUserId;

Update UserDetails_tbl
set IsEmailVerified=0,
EmailCode=null,
EmailCodeInsertedDate=null
where User_Id=IUserId;
End;
End if;

Select 'success' as status;

ENd