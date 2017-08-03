INSERT INTO UserImages_tbl( Path, 
TYPE , AssociatedId, UserId ) 
SELECT Imagepath, 3, vdt.VenueId, UserId
FROM VenueDetails_tbl vdt
INNER JOIN VenueImages_tbl vit ON vdt.Venueid = vit.Venueid