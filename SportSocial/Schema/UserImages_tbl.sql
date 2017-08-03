DROP TABLE IF EXISTS `UserImages_tbl`;
CREATE TABLE IF NOT EXISTS `UserImages_tbl` (
  `ImageId` int(11) NOT NULL AUTO_INCREMENT,
  `Path` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Text` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Type` int(11) DEFAULT NULL,
  `AssociatedId` int(11) DEFAULT NULL,
  `UserId` int(11) NOT NULL,
  `InsertedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ImageId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=212 ;
