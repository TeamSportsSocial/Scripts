Delimiter ;;
Drop procedure if exists getUserNames;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserNames`(IN `IfirstName` VARCHAR(5000), IN `IlastName` VARCHAR(5000))
    NO SQL
Begin

 set @userid=(Select max(user_id) from User_tbl);

 Drop temporary table if exists usernames;
 Create temporary table usernames
SELECT LOWER(Concat(CONCAT(SUBSTRING(IfirstName,1,1),IlastName),@userid))as UserName;


Select Replace(UserName,' ','') as UserName  from usernames un
where not exists
(
Select 1 from User_tbl where Uniquename like UserName
);


End