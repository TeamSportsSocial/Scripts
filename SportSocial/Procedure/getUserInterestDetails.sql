Delimiter ;;
Drop procedure if exists getUserInterestDetails;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserInterestDetails`(IN `IUserId` INT, IN `IProfileId` INT)
    NO SQL
Begin

Select distinct uid.UserId,gqt.Gameid,uid.QuestionId,uid.Answer
from UserInterestDetails_tbl uid
inner join GameQuestions_tbl gqt
on uid.questionid=gqt.questionid;


End