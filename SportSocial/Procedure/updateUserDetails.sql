Delimiter ;;
Drop procedure if exists updateUserDetails	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUserDetails`(IN `IUserid` INT, IN `IUserStatus` VARCHAR(1024), IN `Ifirstname` VARCHAR(1024), IN `Ilastname` VARCHAR(1024), IN `phone` VARCHAR(1024), IN `email` VARCHAR(1024), IN `profilepic` VARCHAR(1024), IN `coverpic` VARCHAR(1024), IN `IDateofBirth` DATETIME, IN `Icity` VARCHAR(1024), IN `work` VARCHAR(1024), IN `study` VARCHAR(1024), IN `academy` VARCHAR(1024), IN `ICurcity` VARCHAR(1024))
    NO SQL
Begin

Update User_tbl
set FirstName=Ifirstname,
LastName=Ilastname,
Emailid=email,
DateofBirth=IDateofBirth,
Mobile=phone,
city=ICurcity
where User_id=IUserid;

Insert into City_tbl(name)
values(ICurcity);

If (profilepic<>'undefined') then
Begin
Update User_tbl
set Profile_Photo_Path=profilepic
where User_id=IUserid;

Insert into UserImages_tbl(Path,Text, Type,AssociatedId,UserId)
values(profilepic,'',1,IUserid,IUserid);


End;
End if;

If (coverpic<>'undefined') then
Begin
Update User_tbl
set Cover_Pic_Path=coverpic
where User_id=IUserid;

Insert into UserImages_tbl(Path,Text, Type,AssociatedId,UserId)
values(coverpic,'',1,IUserid,IUserid);

End;
End if;

If (work<>'undefined') then
Begin
Update UserDetails_tbl
set InstnName=work,
TypeofInstn=3
where User_id=IUserid;

End;
End if;

If (study<>'undefined') then
Begin
Update UserDetails_tbl
set InstnName=study,
TypeofInstn=2
where User_id=IUserid;

End;
End if;


If (academy<>'undefined') then
Begin
Update UserDetails_tbl
set academy=study
where User_id=IUserid;

End;
End if;

If (Icity<>'undefined') then
Begin
Update UserDetails_tbl
set Homecity=Icity
where User_id=IUserid;

Insert into City_tbl(name)
values(Icity);

End;
End if;

End