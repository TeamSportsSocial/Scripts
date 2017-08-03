Delimiter ;;
Drop procedure if exists getAcademicsSuggestions;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getAcademicsSuggestions`(IN `str` VARCHAR(2000), IN `IUserId` INT)
BEGIN


set @str=REPLACE(str,' ',';');

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
Name varchar(2000),
searchType int,
rn int
);
set @i=1;


while(@i>0) do
set @res=SPLIT_STRING(@str,';',@i);

if(@res is null || @res='') then
begin
set @i=-1;
End;
else
Begin




Insert into searchuseresult
Select Academy,1  as searchtype,Locate(@res,Academy) as rn
from UserDetails_tbl utt
where Locate(@res,Academy)>0;



End;
End if;

set @i=@i+1;
End while;


Select distinct name,searchtype,rn from searchuseresult
where name <> ''
order by searchtype,rn;
End