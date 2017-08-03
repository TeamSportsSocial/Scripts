Delimiter ;;
Drop procedure if exists registerUser;;

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerUser`(IN `firtsname` TEXT, IN `lastname` TEXT, IN `mailid` TEXT, IN `username` TEXT, IN `mobileno` TEXT, IN `Gender` VARCHAR(100), IN `password` TEXT, IN `DOB` DATE)
    NO SQL
Begin

if(IsFbUser="Facebook") then
Begin
Update User_tbl
set UniqueName=username,
password=Ipassword
where userid=IUserId;

Select User_Id as UserId,User_Name,UniqueName,EmailId,"True" as IsSuccessfull
from User_tbl
where User_id=IUserId;
End;
Else
Begin

Insert into User_tbl(UniqueName,FirstName,LastName,EmailId,DateofBirth,Mobile,Gender,password)
values(username,firtsname,lastname,mailid,DOB,mobileno,Gender,Ipassword);




set @userid=(Select last_insert_id());

Insert into UserDetails_tbl(User_id)
values(@userid);

Update User_tbl
set User_Name=CONCAT(FirstName,Concat(' ',case when LastName ='undefined' then '' else LastName end))
where user_id=@userid;

Select User_Id as UserId,User_Name,UniqueName,EmailId,"True" as IsSuccessfull
from User_tbl
where User_id=@userid;
End;
End if;

End