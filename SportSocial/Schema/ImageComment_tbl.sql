DROP TABLE IF EXISTS `ImageComment_tbl`;
CREATE TABLE IF NOT EXISTS `ImageComment_tbl` (
  `CommentId` int(11) NOT NULL AUTO_INCREMENT,
  `ImageId` int(11) DEFAULT NULL,
  `Comment` text COLLATE utf8_unicode_ci,
  `UserId` int(11) NOT NULL,
  `InsertedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`CommentId`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=7 ;
