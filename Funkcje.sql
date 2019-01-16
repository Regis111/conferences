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
	join WorkShop ws on ws.WorkShopID = wsr.WorkShopID
	join ConferenceDays cd on cd.ConferenceDayID = ws.ConferenceDayID and cd.ConferenceID = @ConferenceID
	join WorkShopParticipant wsp on wsp.WorkShopReservationID = wsr.WorkShopReservationID
	join ConferenceParticipant cp on wsp.ConferenceParticipantID = cp.ConferenceParticipantID
	left join Student s on s.ConferenceParticipantID = cp.ConferenceParticipantID
	where cp.ConferenceParticipantID is null)
	+
	(select sum(StudentTicket) from WorkShopReservation wsr
	join WorkShop ws on ws.WorkShopID = wsr.WorkShopID
	join ConferenceDays cd on cd.ConferenceDayID = ws.ConferenceDayID and cd.ConferenceID = @ConferenceID
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
	join ConferenceDays cd on cd.ConferenceDayID = cdr.ConferenceDayID and cd.ConferenceID = @ConferenceID
	join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	join ConferenceParticipant cp on cdp.ConferenceParticipantID = cp.ConferenceParticipantID
	left join Student s on s.ConferenceParticipantID = cp.ConferenceParticipantID
	where cp.ConferenceParticipantID is null)
	+
	(select sum(StudentTicket) from ConferenceDayReservation cdr
	join ConferenceDays cd on cd.ConferenceDayID = cdr.ConferenceDayID and cd.ConferenceID = @ConferenceID
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
		(select SUM(SeatsLimit) from WorkShop where ConferenceDayID = @DayID)
		-
		(select COUNT(wsp.ConferenceParticipantID) from WorkShop w
		join WorkShopReservation wsr on wsr.WorkShopID = w.WorkShopID
		join WorkShopParticipant wsp on wsp.WorkShopReservationID = wsr.WorkShopReservationID
		where w.ConferenceDayID = @DayID)
	)
end

--d) czy dwa warsztaty s¹ w tym samym czasie 

create function [FUNC_AreTheseWorkShopsAtTheSameTime] (@WorkShop1ID int, @WorkShop2ID int)
	returns bit
as
begin
	if not exists (select * from WorkShop where WorkShopID = @WorkShop1ID) or not exists (select * from WorkShop where WorkShopID = @WorkShop2ID)
	begin;
		throw 50001,'Wrong parameter - There is no such ConferenceDay in database',1
	end
	
	declare @start1 datetime = (select StartTime from WorkShop where WorkShopID = @WorkShop1ID)
	declare @end1 datetime = (select EndTime from WorkShop where WorkShopID = @WorkShop1ID)
	declare @start2 datetime = (select StartTime from WorkShop where WorkShopID = @WorkShop2ID)
	declare @end2 datetime = (select EndTime from WorkShop where WorkShopID = @WorkShop2ID)
	
	if @start1 < @start2 and @start2 < @end1
		return 1
	
	if @start2 < @start1 and @start1 < @end2
		return 1

	if @start1 <= @start2 and @end1 >= @end2
		return 1

	if @start2 <= @start1 and @end2 >= @end1
		return 1

	return 0
end

--e) iloœæ wolnych miejsc na konkretny warsztat

create function [FUNC_AvailableSeatsOnWorkShop](@WorkShopID int)
	returns int
as
begin
	if not exists (select * from WorkShop where WorkShopID = @WorkShopID)
	begin;
			throw 50001,'Wrong parameter - There is no such WorkShop in database',1
	end

	return(
		(select SeatsLimit from WorkShop where WorkShopID = @WorkShopID) - 
		(select * from WorkShop w
		join WorkShopReservation wsr on wsr.WorkShopID = w.WorkShopID
		join WorkShopParticipant wsp on wsp.WorkShopReservationID = wsr.WorkShopReservationID
		where w.WorkShopID = @WorkShopID) 
	)
end

--f) koszt konkretnej rezerwacji (na podstawie paymentDate) (wzór do wyznaczania ustalamy na (1-x)*price) price-koszt bez ustalania daty p³atnoœci, x - liczba dni od konferencji/100

--g) lista dni konkretnej konferencji
create function [FUNC_DaysOfConference] (@ConferenceID int)
	returns table
as 
begin
	begin try
		if not exists (select * from Conferences where ConferenceID = @ConferenceID)
		begin;
				throw 50001,'Wrong parameter - There is no such Conference in database',1
		end
	
		return (
			select * from ConferenceDays where @ConferenceID = 
		)
	end try


	try catch

	end catch

end

--h) lista participantów na konferencji

--i) lista participantów na konkretny dzieñ

--j) lista participantów na konkretny warsztat

--k) lista wszystkich warsztatów participanta na konkretn¹ konferencjê
