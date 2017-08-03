DROP TABLE IF EXISTS `UserDetails_tbl`;
CREATE TABLE IF NOT EXISTS `UserDetails_tbl` (
  `User_Id` int(11) NOT NULL,
  `TypeofInstn` int(11) DEFAULT NULL,
  `InstnName` text COLLATE utf8_unicode_ci,
  `PreviousInstnType` int(11) DEFAULT NULL,
  `PreviousInstnName` text COLLATE utf8_unicode_ci,
  `Academy` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `HomeCity` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `MobileVerificationCode` int(11) DEFAULT NULL,
  `MobCodeInserteddate` datetime DEFAULT NULL,
  `Emailcode` varchar(5000) COLLATE utf8_unicode_ci DEFAULT NULL,
  `EmailCodeInserteddate` datetime DEFAULT NULL,
  `IsEmailVerified` int(11) NOT NULL DEFAULT '0',
  `IsPhoneVerified` int(11) NOT NULL DEFAULT '0',
  `ProfileImageId` int(11) DEFAULT NULL,
  `InsertedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `User_Id` (`User_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
