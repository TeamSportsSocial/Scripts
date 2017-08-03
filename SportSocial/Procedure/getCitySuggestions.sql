Delimiter ;;
Drop procedure if exists getCitySuggestions;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getCitySuggestions`(IN `str` VARCHAR(2000), IN `IUserId` INT)
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
Select name as City,1  as searchtype,Locate(@res,name) as rn
from City_tbl utt
where Locate(@res,name)>0;





Insert into searchuseresult
Select name as City,1  as searchtype,Locate(name,@res) as rn
from City_tbl utt
where Locate(name,@res)>0;


End;
End if;

set @i=@i+1;
End while;


Select distinct name,searchtype,rn,count(*) as MatchCount
from searchuseresult ser
left join VenueDetails_tbl vdt
on ser.name=vdt.City
left join Event_tbl et
on et.Venue_id=vdt.VenueId
where name <> ''
group by  name,searchtype,rn 
order by searchtype,rn;
End