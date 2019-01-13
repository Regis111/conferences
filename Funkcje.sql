--Funkcje

--a)zarobek za jedn¹ konferencjê z samych warsztatów 
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

--b) zarobek za jedn¹ konferencjê z samych dni konferencji 

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


--c)  iloœæ wolnych miejsc na konkretny dzieñ (suma wolnych miejsc na wszystkich warsztatach na ten dzieñ)

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

--d) 
create function [FUNC_AreTheseWorkShopsAtTheSameTime] (@WorkShop1ID int, @WorkShop2ID int)
	returns bit
as
begin
	if not exists (select * from WorkShop where WorkShopID = @WorkShop1ID) or not exists (select * from WorkShop where WorkShopID = @WorkShop2ID)
	begin;
		throw 50001,'Wrong parameter - There is no such ConferenceDay in database',1
	end
	
	declare @startTime1 time
	declare @endTime1 time
	declare @startTime2 time
	declare @endTime2 time
	
	set @startTime1 = (select StartTime from WorkShop where WorkShopID = @WorkShop1ID)
	set @endTime1 = (select EndTime from WorkShop where WorkShopID = @WorkShop1ID)
	set @startTime2 = (select StartTime from WorkShop where WorkShopID = @WorkShop2ID)
	set @endTime2 = (select EndTime from WorkShop where WorkShopID = @WorkShop2ID)
	
	

end