--Funkcje

--a)
create function [FUNC_PaymentForWorkShops] (@ConferenceID int)	
	returns int
as
begin
	
	if not exists (select * from Conferences where ConferenceID = @ConferenceID)
	begin;
		throw 50001,'Wrong parameter - There is no such Conference in database',1
	end
	
	return
	(
	(select sum(NormalTicket) from WorkShopReservation wsr
	join WorkShopParticipant wsp on wsp.WorkShopReservationID = wsr.WorkShopReservationID
	join ConferenceParticipant cp on wsp.ConferenceParticipantID = cp.ConferenceParticipantID
	left join Student s on s.ConferenceParticipantID = cp.ConferenceParticipantID
	where cp.ConferenceParticipantID is null)
	+
	(select sum(StudentTicket) from WorkShopReservation wsr
	join WorkShopParticipant wsp on wsp.WorkShopReservationID = wsr.WorkShopReservationID
	join ConferenceParticipant cp on wsp.ConferenceParticipantID = cp.ConferenceParticipantID
	join Student s on s.ConferenceParticipantID = cp.ConferenceParticipantID)
	)
end

--b)

create function [FUNC_PaymentForDays] (@ConferenceID int)
	returns int
as
begin
	
	if not exists (select * from Conferences where ConferenceID = @ConferenceID)
	begin;
		throw 50001,'Wrong parameter - There is no such Conference in database',1
	end

	return
	(
	(select sum(NormalTicket) from ConferenceDayReservation cdr
	join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	join ConferenceParticipant cp on cdp.ConferenceParticipantID = cp.ConferenceParticipantID
	left join Student s on s.ConferenceParticipantID = cp.ConferenceParticipantID
	where cp.ConferenceParticipantID is null)
	+
	(select sum(StudentTicket) from ConferenceDayReservation cdr
	join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	join ConferenceParticipant cp on cdp.ConferenceParticipantID = cp.ConferenceParticipantID
	join Student s on s.ConferenceParticipantID = cp.ConferenceParticipantID)
	)
end


c)

create function [FUNC_NumberOfAvailableSeatsOnDay] (@DayID int)
	returns int
as
begin
	
	if not exists (select * from ConferenceDays where ConferenceDayID = @DayID)
	begin;
		throw 50001,'Wrong parameter - There is no such ConferenceDay in database',1
	end

	return(
		select sum(SeatsLimit - ReservedSeats) from WorkShop w
		join ConferenceDays cd on cd.ConferenceDayID = w.ConferenceDayID
		where cd.ConferenceDayID = @DayID
	)
end

d)

