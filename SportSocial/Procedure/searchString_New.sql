Delimiter ;;
Drop procedure if exists searchString_New	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `searchString_New`(IN `str` VARCHAR(2000), IN `IUserId` INT, IN `searchType` INT)
BEGIN


set @str=REPLACE(str,' ',';');

drop temporary table if exists searchuseresult;
Create temporary table searchuseresult(
id int,
Name varchar(2000),
image varchar(2000),
searchType int
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
Select utt.user_id,utt.user_name,Profile_Photo_Path,0 as searchtype from
UserInterest_tbl uit
inner join searchresults srt
on srt.gameid=uit.gameid
inner join User_tbl utt
on utt.user_id=uit.user_id;

drop temporary table if exists searchresults;
create temporary table searchresults
Select Locate(FirstName,@res) as rn,user_id as Id,0 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,FirstName) as rn,user_id as Id,0 as searchtype from User_tbl;

Insert into searchresults
Select Locate(LastName,@res) as rn,user_id as Id,0 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,LastName) as rn,user_id as Id,0 as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,User_Name) as rn,user_id as Id,0 as searchtype from User_tbl;


Insert into searchresults
Select Locate(User_Name,@res) as rn,user_id as Id,0 as searchtype from User_tbl;

Insert into searchresults
Select Locate(City,@res) as rn,user_id as Id, 0  as searchtype from User_tbl;

Insert into searchresults
Select Locate(@res,Address) as rn,VenueId as Id, 1  as searchtype from VenueDetails_tbl;


Insert into searchresults
Select Locate(Address,@res) as rn,VenueId as Id, 1  as searchtype from VenueDetails_tbl;

Delete ser from searchresults ser where rn=0;


Insert into searchuseresult
Select utt.user_id,utt.user_name,Profile_Photo_Path,0 as resulttype from
searchresults srt
inner join User_Playmates_tbl upt
on upt.userid=srt.id 
inner join User_tbl utt
on utt.user_id=upt.frienduserid
where searchtype=0;

Insert into searchuseresult
Select utt.user_id,utt.user_name,Profile_Photo_Path,0 as resulttype from
searchresults srt
inner join User_Playmates_tbl upt
on upt.frienduserid =srt.id 
inner join User_tbl utt
on utt.user_id=upt.userid
where searchtype=0;


Insert into searchuseresult
Select utt.user_id,utt.user_name,Profile_Photo_Path,0 as resulttype from
searchresults srt
inner join User_tbl utt
on utt.user_id=srt.id
where searchtype=0;


Insert into searchuseresult
Select utt.VenueId,utt.Venue_Name,'',1 as resulttype from
searchresults srt
inner join VenueDetails_tbl utt
on utt.VenueId=srt.id
where searchtype=1;

End;
End if;

set @i=@i+1;
End while;


Select distinct id,name,image,searchType from searchuseresult
order by searchtype desc;
End