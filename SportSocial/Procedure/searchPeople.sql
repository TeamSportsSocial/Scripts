Delimiter ;;
Drop procedure if exists searchPeople	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchPeople`(IN `str` VARCHAR(2000), IN `IUserId` INT, IN `IsearchType` INT, IN `limiter` INT, IN `skip` INT)
BEGIN


set @str=REPLACE(str,' ',';');

set @limiter=limiter;
set @skip=skip;


drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
id int,
Name varchar(2000),
image varchar(2000),
searchType int null,
sortorder int null,
IsPlaymate int null
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
Select utt.user_id,utt.user_name,Profile_Photo_Path,1 as searchtype,1000,null from
UserInterest_tbl uit
inner join searchresults srt
on srt.gameid=uit.gameid
inner join User_tbl utt
on utt.user_id=uit.user_id;




drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(FirstName,@res) as rn,user_id as Id,1 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,FirstName) as rn,user_id as Id,1 as searchtype from User_tbl;

Insert into searchresults
Select Locate(LastName,@res) as rn,user_id as Id,1 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,LastName) as rn,user_id as Id,1 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,User_Name) as rn,user_id as Id,1 as searchtype from User_tbl;


Insert into searchresults
Select Locate(User_Name,@res) as rn,user_id as Id,1 as searchtype from User_tbl;

Insert into searchresults
Select Locate(City,@res) as rn,user_id as Id, 1  as searchtype from User_tbl
where City<>'';

Insert into searchresults
Select Locate(@res,City) as rn,user_id as Id, 1  as searchtype from User_tbl
where City<>'';

Delete ser from searchresults ser where rn=0;


Insert into searchuseresult
Select utt.user_id,utt.user_name,Profile_Photo_Path,searchtype,1000,null from
searchresults srt
inner join User_tbl utt
on utt.user_id=srt.id;





End;
End if;

set @i=@i+1;
End while;


drop temporary table if exists searchDistinctResult;
Create temporary table searchDistinctResult
Select distinct ser.* from searchuseresult ser;

drop temporary table if exists searchResultFinal;
Create temporary table searchResultFinal(
id int,
Name varchar(2000),
image varchar(2000),
searchType int null,
sortorder int null,
IsPlaymate int null
);

set @t1=Concat("
Insert into searchResultFinal
Select distinct ser.* from searchDistinctResult ser limit ");
set @t2=Concat(@skip,",",@limiter);

set @t3=Concat(@t1,@t2);

prepare getfeed from @t3;
Execute getfeed;
deallocate prepare getfeed;


Update searchResultFinal srt
set sortorder=10000,
IsPlaymate=0
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.userid=srt.id
and upt.frienduserid=IUserId
);


Update searchResultFinal srt
set sortorder=10000,
IsPlaymate=0
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.frienduserid=srt.id
and upt.userid=IUserId
);

Update searchResultFinal srt
set sortorder=10000,
IsPlaymate=0
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.frienduserid=srt.id
and upt.userid=IUserId
);

Update searchResultFinal srt
set sortorder=10000,
IsPlaymate=1
where exists
(
Select 1 from User_Playmates_tbl upt
where upt.userid=srt.id
and upt.frienduserid=IUserId
) and exists
(
Select 1 from User_Playmates_tbl upt
where upt.frienduserid=srt.id
and upt.userid=IUserId
);



Select distinct id,name,image,searchType,sortorder,IsPlaymate, 
case when upt.frienduserid is null then 0 else count(*) end as fancount
from searchResultFinal ser
left join User_Playmates_tbl upt
on upt.frienduserid=ser.id
and status=0
group by id,name,image,searchType,sortorder,IsPlaymate
order by sortorder desc;
End