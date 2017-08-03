Delimiter ;;
Drop procedure if exists searchTrending	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchTrending`(IN `IUserId` INT, IN `str` TEXT, IN `searchType` INT,IN `limiter` INT,IN `skip` INT)
    NO SQL
BEGIN


set @limiter=limiter;
set @skip=skip;

set @str=REPLACE(str,' ',';');

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
Eventid int,
UserId int,
UserName varchar(2000),
GameId int,
GameName varchar(2000),
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
Select Locate(gamename,@res) as rn,gameid,GameName from Game_tbl;

Insert into searchresults
Select Locate(@res,gamename) as rn,gameid,GameName from Game_tbl;

Delete ser from searchresults ser where rn=0;

Insert into searchuseresult
Select Eventid,ut.User_id,User_Name,et.GameId,GameName,et.Event_Image,2 as searchtype,
 ( 3959 * acos( cos( radians(@lat) ) * cos( radians( et.latitude ) ) 
   * cos( radians(et.longitude) - radians(@lon)) + sin(radians(@lat)) 
   * sin( radians(et.latitude)))) 
from Event_tbl et
inner join searchresults srt
on srt.gameid=et.gameid
inner join User_tbl ut
on ut.user_id=et.user_id;

drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(gamename,@res) as rn,gameid from Game_tbl;




drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(FirstName,@res) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,FirstName) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(LastName,@res) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,LastName) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,User_Name) as rn,user_id as Id,2 as searchtype from User_tbl;


Insert into searchresults
Select Locate(User_Name,@res) as rn,user_id as Id,2 as searchtype from User_tbl;

Insert into searchresults
Select Locate(City,@res) as rn,user_id as Id, 2  as searchtype from User_tbl
where City<>'';

Insert into searchresults
Select Locate(@res,City) as rn,user_id as Id, 2  as searchtype from User_tbl
where City<>'';

Delete ser from searchresults ser where rn=0;




Insert into searchuseresult
Select Eventid,ut.User_id,User_Name,gt.GameId,GameName,et.Event_Image,2 as searchtype,
 ( 3959 * acos( cos( radians(@lat) ) * cos( radians( et.latitude ) ) 
   * cos( radians(et.longitude) - radians(@lon)) + sin(radians(@lat)) 
   * sin( radians(et.latitude)))) 
from Event_tbl et
inner join searchresults srt
on srt.id=et.user_id
inner join User_tbl ut
on ut.user_id=et.user_id
inner join Game_tbl gt
on gt.gameid=et.gameid;


set @count=(Select count(*) from searchuseresult);
if(@count>(@skip+@limiter)) then
Begin
set @i=-1;
End;
End if;


End;
End if;

set @i=@i+1;
End while;


set @t1=Concat("
Select ser.Eventid,ser.UserId,UserName,GameId,GameName,image,searchType,sortorder,count(*) as WatchCount
from searchuseresult ser
left join EventWatch_tbl ilt 
on ser.Eventid=ilt.eventid
group by ser.Eventid,ser.UserId,UserName,GameId,GameName,image,searchType,sortorder limit ");
set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;

End