DROP TABLE IF EXISTS `InstnType_tbl`;
CREATE TABLE IF NOT EXISTS `InstnType_tbl` (
  `InstnTypeId` int(11) NOT NULL,
  `InstnTypeName` varchar(1000) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
