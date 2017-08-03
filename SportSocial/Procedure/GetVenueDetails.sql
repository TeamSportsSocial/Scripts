Delimiter ;;
Drop procedure if exists GetVenueDetails;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetVenueDetails`(IN `Game_Id` INT)
    NO SQL
Select vt.VenueId,vt.Latitude,vt.Longitude,Venue_Name,Address,gameid,Category as VenueCategory
from VenueDetails_tbl vt
inner join VenueSports_tbl vst
on vt.venueid=vst.venueid
where VenueType=1
limit 100000