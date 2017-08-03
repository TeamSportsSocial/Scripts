Delimiter ;;
Drop procedure if exists venueAddImages	;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `venueAddImages`(IN `VenueId` INT, IN `Path` VARCHAR(5000))
    NO SQL
Begin

Insert into VenueImages_tbl(Venueid,Imagepath)
values(VenueId,Path);

Insert into UserImages_tbl(Path,Type,AssociatedId)
values(Path,3,VenueId);

End