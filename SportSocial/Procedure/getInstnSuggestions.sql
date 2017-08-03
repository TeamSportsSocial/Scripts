Delimiter ;;
Drop procedure if exists getInstnSuggestions;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getInstnSuggestions`(IN `str` VARCHAR(2000), IN `IUserId` INT)
BEGIN


set @str=REPLACE(str,' ',';');

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
Name varchar(2000),
searchType int,
rn int
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
Select InstnName,1  as searchtype,Locate(@res,InstnName) as rn
from UserDetails_tbl utt
where Locate(@res,InstnName)>0;


Insert into searchuseresult
Select InstnName,1  as searchtype,Locate(@res,InstnName) as rn
from UserDetails_tbl utt
where Locate(InstnName,@res)>0;

Insert into searchuseresult
Select PreviousInstnName,1  as searchtype,Locate(@res,PreviousInstnName) as rn
from UserDetails_tbl utt
where Locate(PreviousInstnName,@res)>0;


Insert into searchuseresult
Select PreviousInstnName,1  as searchtype,Locate(PreviousInstnName,@res) as rn
from UserDetails_tbl utt
where Locate(@res,PreviousInstnName)>0;





End;
End if;

set @i=@i+1;
End while;


Select distinct name,searchtype,rn from searchuseresult
order by searchtype,rn;
End