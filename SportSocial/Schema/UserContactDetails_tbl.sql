DROP TABLE IF EXISTS `UserContactDetails_tbl`;
CREATE TABLE IF NOT EXISTS `UserContactDetails_tbl` (
  `ContactId` int(11) NOT NULL AUTO_INCREMENT,
  `UserId` int(11) NOT NULL,
  `UserName` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `Contact` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ContactId`),
  KEY `Contact_Userid` (`UserId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=971 ;
