Delimiter ;;
Drop procedure if exists getGameDetails;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getGameDetails`()
    NO SQL
Begin

Select gt.GameId,GameName,count(*) as PlayerCount 
from Game_tbl gt
left join UserInterest_tbl uit
on gt.gameid=uit.gameid
group by gt.gameid,GameName;

Select * from GameQuestions_tbl;

Select * from GameQuestions_Answers_tbl;


End