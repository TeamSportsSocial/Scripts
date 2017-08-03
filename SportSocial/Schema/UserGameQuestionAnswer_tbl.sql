DROP TABLE IF EXISTS `UserGameQuestionAnswer_tbl`;
CREATE TABLE IF NOT EXISTS `UserGameQuestionAnswer_tbl` (
  `Id` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `QuestionId` int(11) NOT NULL,
  `Answer` int(11) NOT NULL,
  `InsertedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
