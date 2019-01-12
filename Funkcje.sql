--a)
create function [FUNC_PaymentForWorkShops] (@ReservationID int)	
	returns int
as
begin
	declare @ConferenceID int
	set @ConferenceID = (select ConferenceID from Reservations r where r.ReservationID = @ReservationID)
	return
	(
	select sum(Price) from WorkShopReservation
	where WorkShopID in 
			(select WorkShopID from WorkShop where ConferenceDayID in
							(select ConferenceDayID from ConferenceDays where ConferenceDayID = @ConferenceID
							)
			)
	)	
end

b)


