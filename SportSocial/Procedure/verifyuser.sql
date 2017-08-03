Delimiter ;;
Drop procedure if exists verifyuser	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `verifyuser`(IN `Iuserid` INT, IN `Iverificationcode` VARCHAR(10), IN `newcode` VARCHAR(10))
BEGIN
if exists(Select 1 from User_tbl where user_id=Iuserid and Verificationcode=Iverificationcode and Timestampdiff(Hour,Inserteddate,curdate())<2) then
Begin
                            
Update User_tbl
set IsValidated=1,
Inserteddate=Now()
where user_id=Iuserid;
          
Select "true" as IsVerified,Iuserid;
          
End;
else
Begin
set @inserteddate=(Select inserteddate from User_tbl where user_id=Iuserid);
if(Timestampdiff(Hour,@inserteddate,curdate())>2) then
Begin
                  
Update User_tbl
set Verificationcode=newcode,
Inserteddate=Now()
where user_id=Iuserid;

Select "false" as IsVerified,"true" as Isnewcodesent,Iuserid,emailid
from User_tbl where user_id=Iuserid;


End;
else
BEgin
Select "false" as IsVerified,"false" as Isnewcodesent,Iuserid,emailid
from User_tbl where user_id=Iuserid;      
End;
End if;
End;
End if;

End