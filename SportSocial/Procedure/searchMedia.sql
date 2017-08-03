Delimiter ;;
Drop procedure if exists searchMedia	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchMedia`(IN `str` VARCHAR(2000), IN `IUserId` INT, IN `IsearchType` INT, IN `limiter` INT, IN `skip` INT)
BEGIN


set @str=REPLACE(str,' ',';');

set @limiter=limiter;
set @skip=skip;
set @userid=IUserId;

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
id int,
Name varchar(2000),
image varchar(2000),
searchType int null,
sortorder int null
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
drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(gamename,@res) as rn,gameid from Game_tbl;

Insert into searchresults
Select Locate(@res,gamename) as rn,gameid from Game_tbl;

Delete ser from searchresults ser where rn=0;

Insert into searchuseresult
Select Imageid,Text,Path,2 as searchtype,null
from Event_tbl et
inner join searchresults srt
on srt.gameid=et.gameid
inner join UserImages_tbl uit
on et.Eventid=uit.AssociatedId
where uit.Type=2;


drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(FirstName,@res) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,FirstName) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(LastName,@res) as rn,user_id as Id,3 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,LastName) as rn,user_id as Id,3 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,User_Name) as rn,user_id as Id,4 as searchtype from User_tbl;


Insert into searchresults
Select Locate(User_Name,@res) as rn,user_id as Id,4 as searchtype from User_tbl;

Insert into searchresults
Select Locate(City,@res) as rn,user_id as Id, 5  as searchtype from User_tbl
where City<>'';

Insert into searchresults
Select Locate(@res,City) as rn,user_id as Id, 5  as searchtype from User_tbl
where City<>'';

Delete ser from searchresults ser where rn=0;

Insert into searchuseresult
Select Imageid,text,Path,searchtype,null from
searchresults srt
inner join UserImages_tbl uit 
on uit.AssociatedId=srt.id
and uit.type=1;

Insert into searchuseresult
Select Imageid,text,Path,searchtype,null from
searchresults srt
inner join Event_tbl et
on srt.id=et.user_id
inner join UserImages_tbl uit 
on uit.AssociatedId=et.eventid
and uit.type=2;


End;
End if;

set @i=@i+1;
End while;

set @t1=Concat("Select distinct id,name,image,searchType,sortorder,liked
from searchuseresult ser
left join ImageLike_tbl ilt 
on ser.id=ilt.imageid
and ilt.userid=",@userid,"
order by sortorder asc
limit ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;


End