DROP TABLE IF EXISTS `GameQuestions_Answers_tbl`;
CREATE TABLE IF NOT EXISTS `GameQuestions_Answers_tbl` (
  `AnsId` int(11) NOT NULL AUTO_INCREMENT,
  `QuestionId` int(11) NOT NULL,
  `Answer` varchar(10000) COLLATE utf8_unicode_ci NOT NULL,
  `Inserteddate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`AnsId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=242 ;
