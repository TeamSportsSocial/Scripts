Delimiter ;;
Drop procedure if exists searchSuggestions	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchSuggestions`(IN `str` VARCHAR(2000), IN `IUserId` INT)
BEGIN
SET sql_mode = '';

set @str=REPLACE(str,' ',';');

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
Name varchar(2000),
Id int default 0,
Profile_Photo varchar(5000) default "",
searchType int
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


Insert into searchuseresult(id,name,searchType)
Select distinct Gameid,GameName,2 as searchtype from Game_tbl
where Locate(gamename,@res)>0;

Insert into searchuseresult(id,name,searchType)
Select distinct Gameid,GameName,2 as searchtype from Game_tbl
where Locate(@res,gamename)>0;

Insert into searchuseresult(name,searchType)
Select distinct City,3 as searchtype from User_tbl
where Locate(City,@res)>0;

Insert into searchuseresult(name,searchType)
Select distinct  City,3  as searchtype from User_tbl
where Locate(@res,City)>0;


Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1 as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and Locate(FirstName,@res)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and Locate(@res,FirstName)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and Locate(FirstName,@res)>0;


Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and Locate(@res,FirstName)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and Locate(LastName,@res)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and Locate(@res,LastName)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and Locate(LastName,@res)>0 or Locate(@res,LastName)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where utt.user_id=IUserId
and Locate(User_Name,@res)>0 or Locate(@res,User_Name)>0;

Insert into searchuseresult(name,id,Profile_Photo,searchType)
Select FirstName,User_id,Profile_Photo_Path,1  as searchtype
from User_Playmates_tbl upt
inner join User_tbl utt
on utt.user_id=upt.userid
where utt.user_id=IUserId
and Locate(User_Name,@res)>0 or Locate(@res,User_Name)>0;

Insert into searchuseresult(name,id,searchType)
Select distinct  Venue_Name,VenueId,4  as searchtype from VenueDetails_tbl
where Locate(@res,Address)>0 or Locate(Address,@res)>0;

-- Insert into searchuseresult
-- Select utt.user_id,utt.user_name,Profile_Photo_Path,0 as resulttype,
--  ( 3959 * acos( cos( radians(@lat) ) * cos( radians( utt.latitude ) ) 
--    * cos( radians(utt.longitude) - radians(@lon)) + sin(radians(@lat)) 
--    * sin( radians(utt.latitude))))+100000   from
-- searchresults srt
-- inner join User_Playmates_tbl upt
-- on upt.userid=srt.id 
-- inner join User_tbl utt
-- on utt.user_id=upt.frienduserid
-- where searchtype=0;

drop temporary table if exists searchuseresultdummy;
Create temporary table searchuseresultdummy
Select * from searchuseresult
limit 20;

Alter table searchuseresultdummy Add Index `serid`(id);


drop temporary table if exists searchuseresultfinal;
Create temporary table searchuseresultfinal
Select distinct name,id,Profile_Photo,searchType,count(*) as PlayerCount,null as Start_Date,0 as GameId
from searchuseresultdummy ser
left join Event_tbl et
on ser.id=et.Venue_Id
left join Event_Joinees_tbl ejt
on et.eventid=ejt.eventid
where searchType=4
group by name,id,Profile_Photo,searchType
limit 10;

Insert into searchuseresultfinal
Select distinct name,id,Profile_Photo,searchType,count(*) as PlayerCount,null as Start_Date,0 as GameId
from searchuseresultdummy ser
left join Venue_tbl vdt
on ser.name=vdt.venue_name
left join Event_tbl et
on vdt.Venueid=et.Venue_Id
left join Event_Joinees_tbl ejt
on et.eventid=ejt.eventid
where searchType=3
group by name,id,Profile_Photo,searchType
limit 10;


drop temporary table if exists searchuseresultevent;
Create temporary table searchuseresultevent
Select distinct id,max(et.Eventid) as eventid
from searchuseresultdummy ser
left join Event_Joinees_tbl ejt 
on ejt.Userid=ser.id
left join Event_tbl et
on et.eventid=ejt.eventid
where searchType=1
group by id
limit 10;

Insert into searchuseresultfinal
Select distinct name,ser.id,Profile_Photo,searchType,0 as PlayerCount,Start_Date,GameId
from searchuseresultdummy ser
inner join searchuseresultevent sre
on ser.id=sre.id
left join Event_tbl et
on et.eventid=sre.eventid
where searchType=1
limit 10;


Insert into searchuseresultfinal
Select distinct name,id,Profile_Photo,searchType,count(*) as PlayerCount,null as Start_Date,0 as GameId
from searchuseresultdummy ser
left join Event_tbl et
on ser.id=et.Gameid
where searchType=2
group by name,id,Profile_Photo,searchType
limit 10;

End;
End if;

set @i=@i+1;
End while;


Select distinct name,id,Profile_Photo,searchType,PlayerCount,Start_Date, GameId from searchuseresultfinal
where name <>""
order by searchtype desc
limit 10;
End