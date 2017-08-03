DROP TABLE IF EXISTS `UserGameSpecification_tbl`;
CREATE TABLE IF NOT EXISTS `UserGameSpecification_tbl` (
  `SpecificationId` int(11) NOT NULL,
  `UserId` int(11) NOT NULL,
  `GameId` int(11) NOT NULL,
  `QuestionId` int(11) NOT NULL,
  `Answer` text COLLATE utf8_unicode_ci NOT NULL,
  `InsertedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
