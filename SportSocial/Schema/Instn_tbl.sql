
DROP TABLE IF EXISTS `Instn_tbl`;
CREATE TABLE IF NOT EXISTS `Instn_tbl` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `InsertedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;
