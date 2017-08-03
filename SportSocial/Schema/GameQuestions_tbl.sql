DROP TABLE IF EXISTS `GameQuestions_tbl`;
CREATE TABLE IF NOT EXISTS `GameQuestions_tbl` (
  `QuestionId` int(11) NOT NULL AUTO_INCREMENT,
  `GameId` int(11) NOT NULL,
  `Question` text COLLATE utf8_unicode_ci NOT NULL,
  `Icon` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `QuestionType` int(11) DEFAULT NULL,
  `InsertedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`QuestionId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=224 ;
