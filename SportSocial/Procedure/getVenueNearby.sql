Delimiter ;;
Drop procedure if exists getVenueNearby;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getVenueNearby`(IN `IUserId` INT)
BEGIN


set @lat=(Select latitude from User_tbl where user_id=@usersid);

set @lon=(Select longitude from User_tbl where user_id=@usersid);


Select vt.VenueId,vt.Latitude,vt.Longitude,Venue_Name,Address,0 as gameid,Category as VenueCategory,
( 3959 * acos( cos( radians(@lat) ) * cos( radians( vt.latitude ) ) 
   * cos( radians(vt.longitude) - radians(@lon)) + sin(radians(@lat)) 
   * sin( radians(vt.latitude)))) AS distance,max(ImagePath) as image
from VenueDetails_tbl vt
inner join VenueImages_tbl vit
on vit.Venueid=vt.Venueid
where venuetype=1
group by vt.VenueId,vt.Latitude,vt.Longitude,Venue_Name,Address,Category
order by distance;



End