Delimiter ;;
Drop procedure if exists venueAddPlaygroundNew	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `venueAddPlaygroundNew`(IN `IVenueName` TEXT CHARSET latin1, IN `IVenuePhone` VARCHAR(5000), IN `IVenueSports` LONGTEXT CHARSET latin1, IN `Ivenuedetail` LONGTEXT CHARSET latin1, IN `IAddress` LONGTEXT CHARSET latin1, IN `image1` LONGTEXT, IN `image2` LONGTEXT, IN `image3` LONGTEXT, IN `Ilatitude` DOUBLE(11,9), IN `Ilongitude` DOUBLE(11,9), IN `IEmailid` TEXT, IN `IUserId` INT)
    NO SQL
Begin


DECLARE _next TEXT DEFAULT NULL;
DECLARE _nextlen INT DEFAULT NULL;
DECLARE _value TEXT DEFAULT NULL;
Declare _insertid int Default Null;
Declare _gameid int Default Null;

Insert into VenueDetails_tbl(Venue_Name,Phone,Category,Address,Latitude,Longitude,EmailId,UserId)
values(IVenueName,IVenuePhone,Ivenuedetail,IAddress,Ilatitude,Ilongitude,IEmailid,IUserId);

set _insertid=(SELECT LAST_INSERT_ID());

iterator:
LOOP
  IF LENGTH(TRIM(IVenueSports)) = 0 OR IVenueSports IS NULL THEN
    LEAVE iterator;
  END IF;

 
  SET _next = SUBSTRING_INDEX(IVenueSports,'	',1);


  SET _nextlen = LENGTH(_next);

  
  SET _value = TRIM(_next);

set _gameid=(Select Gameid from Game_tbl where GameName like _next limit 1);

if(_gameid is not null) then
Begin

INSERT INTO VenueSports_tbl (VenueId,GameId,Inserteddate) 
VALUES (_insertid,_gameid,current_timestamp());

End;
End if;
  SET IVenueSports = INSERT(IVenueSports,1,_nextlen + 1,'');
END LOOP;

Select _insertid as Venueid;

if(image1<>'')then
Begin
Insert into VenueImages_tbl(Venueid,Imagepath)
values(_insertid,image1);
End;
End if;

if(image2<>'')then
Begin
Insert into VenueImages_tbl(Venueid,Imagepath)
values(_insertid,image2);
End;
End if;

if(image3<>'')then
Begin
Insert into VenueImages_tbl(Venueid,Imagepath)
values(_insertid,image3);
End;
End if;


End