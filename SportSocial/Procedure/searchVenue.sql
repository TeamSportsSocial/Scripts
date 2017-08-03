Delimiter ;;
Drop procedure if exists searchVenue	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchVenue`(IN `str` VARCHAR(2000), IN `IUserId` INT, IN `IsearchType` INT, IN `limiter` INT, IN `skip` INT)
BEGIN


set @str=REPLACE(str,' ',';');

set @limiter=limiter;
set @skip=skip;
set @lat=(Select latitude from User_tbl where User_Id=IUserId limit 1);
set @lon=(Select longitude from User_tbl where User_Id=IUserId limit 1);

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
Select vdt.VenueId,vdt.Venue_Name,'',2 as searchtype,
 ( 3959 * acos( cos( radians(@lat) ) * cos( radians( vdt.latitude ) ) 
   * cos( radians(vdt.longitude) - radians(@lon)) + sin(radians(@lat)) 
   * sin( radians(vdt.latitude)))) from
VenueSports_tbl uit
inner join searchresults srt
on srt.gameid=uit.gameid
inner join VenueDetails_tbl vdt
on vdt.Venueid=uit.Venueid;

set @count=(Select count(*) from searchuseresult);
if(@count>(@skip+@limiter)) then
Begin
set @i=-1;
End;

else
Begin
drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(@res,Address) as rn,VenueId as Id, 1  as searchtype from VenueDetails_tbl;


Insert into searchresults
Select Locate(Address,@res) as rn,VenueId as Id, 1  as searchtype from VenueDetails_tbl;


Insert into searchuseresult
Select vdt.VenueId,vdt.Venue_Name,'',2 as searchtype,
 ( 3959 * acos( cos( radians(@lat) ) * cos( radians( vdt.latitude ) ) 
   * cos( radians(vdt.longitude) - radians(@lon)) + sin(radians(@lat)) 
   * sin( radians(vdt.latitude)))) 
   from searchresults srt
inner join VenueDetails_tbl vdt
on vdt.Venueid=vdt.Venueid;

Delete ser from searchresults ser where rn=0;
End; 

End if;



End;
End if;

set @i=@i+1;
End while;

drop temporary table if exists searchresultfinal;
create temporary table searchresultfinal
Select ser.*,0 as IsFavourite from searchuseresult ser where 1=0;

set @t1=Concat("
Insert into searchresultfinal
Select distinct id,name,image,searchType,sortorder as distance,0 as IsFavourite
from searchuseresult ser
order by sortorder asc
limit ");

set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;

Select distinct id,name,searchType,sortorder as distance,IsFavourite,count(*) as MatchCount,max(ImagePath) as image
from searchresultfinal ser
inner join VenueImages_tbl vit
on vit.Venueid=ser.id
left join Event_tbl et 
on ser.id=et.Venue_id
group by id,name,searchType,sortorder,IsFavourite;


End