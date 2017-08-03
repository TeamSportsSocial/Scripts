Delimiter ;;
Drop procedure if exists getTagSuggestions;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getTagSuggestions`(IN `str` VARCHAR(2000), IN `IUserId` INT)
BEGIN


set @str=REPLACE(str,' ',';');

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
Name varchar(2000),
id int,
searchType int,
rn int,
profile_photo varchar(2048)
);
set @i=1;

set @lat=(Select latitude from User_tbl where user_id=IUserId limit 1);
set @lon=(Select longitude from User_tbl where user_id=IUserId limit 1);

while(@i>0) do
set @res=SPLIT_STRING(@str,';',@i);

if(@res is null || @res='') then
begin
set @i=-1;
End;
else
Begin


Insert into searchuseresult
Select Uniquename,user_id,1  as searchtype,Locate(FirstName,@res) as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(FirstName,@res)>0;

Insert into searchuseresult
Select Uniquename,user_id,1  as searchtype,Locate(@res,FirstName) as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(@res,FirstName)>0;

Insert into searchuseresult
Select Uniquename,user_id,1  as searchtype,Locate(FirstName,@res) as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(FirstName,@res)>0;


Insert into searchuseresult
Select Uniquename,user_id,1  as searchtype,Locate(@res,FirstName) as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(@res,FirstName)>0;

Insert into searchuseresult
Select Uniquename,user_id,2  as searchtype,Locate(LastName,@res) as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(LastName,@res)>0;

Insert into searchuseresult
Select Uniquename,user_id,2  as searchtype,Locate(@res,LastName),Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(@res,LastName)>0;

Insert into searchuseresult
Select Uniquename,user_id,2  as searchtype,Locate(LastName,@res),Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(LastName,@res)>0;

Insert into searchuseresult 
Select Uniquename,user_id,3  as searchtype,10 as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(User_Name,@res)>0 or Locate(@res,User_Name)>0;

Insert into searchuseresult
Select Uniquename,user_id,3  as searchtype,10 as rn,Profile_Photo_Path
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and
Uniquename is not null
and Locate(User_Name,@res)>0 or Locate(@res,User_Name)>0;



Insert into searchuseresult
Select Uniquename,user_id,4  as searchtype,Locate(User_Name,@res),Profile_Photo_Path
from  User_tbl utt
where utt.user_id<>IUserId
and
Uniquename is not null
and Locate(User_Name,@res)>0 ;


Insert into searchuseresult
Select Uniquename,user_id,4  as searchtype,Locate(@res,User_Name),Profile_Photo_Path
from  User_tbl utt
where utt.user_id<>IUserId and
Uniquename is not null and
 Locate(@res,User_Name)>0;




End;
End if;

set @i=@i+1;
End while;


Select distinct name,FirstName,LastName,searchtype,rn,Profile_Photo 
from searchuseresult ser
inner join User_tbl ut
on ut.user_id=ser.id
where name <> ""
order by searchtype,rn
limit 10;
End