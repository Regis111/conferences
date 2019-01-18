--Funkcje

--a)zarobek za jedn� konferencj� z samych warsztat�w
 
--b)  ilo�� wolnych miejsc na konkretny dzie� (suma wolnych miejsc na wszystkich warsztatach na ten dzie�)

create function [FUNC_NumberOfAvailableSeatsOnDay] (@DayID int)
	returns int
as
begin
	
	if not exists (select * from ConferenceDays where ConferenceDayID = @DayID)
	begin;
		raiserror('No such WorkShop',0,1)
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

--d) czy dwa warsztaty s� w tym samym czasie 

create function [FUNC_AreTheseWorkShopsAtTheSameTime] (@WorkShop1ID int, @WorkShop2ID int)
	returns bit
as
begin
	if not exists (select * from WorkShop where WorkShopID = @WorkShop1ID) or not exists (select * from WorkShop where WorkShopID = @WorkShop2ID)
	begin;
		raiserror('No such WorkShop',0,1)
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

--e) ilo�� wolnych miejsc na konkretny warsztat

create function [FUNC_AvailableSeatsOnWorkShop](@WorkShopID int)
	returns int
as
begin
	if not exists (select * from WorkShop where WorkShopID = @WorkShopID)
	begin;
		raiserror('No such WorkShop',0,1)
	end
	return(
		(select SeatsLimit from WorkShop where WorkShopID = @WorkShopID) - 
		(select count(*) from WorkShop w
		join WorkShopReservation wsr on wsr.WorkShopID = w.WorkShopID
		join WorkShopParticipant wsp on wsp.WorkShopReservationID = wsr.WorkShopReservationID
		where w.WorkShopID = @WorkShopID) 
	)
end

--f) koszt konkretnej rezerwacji (na podstawie paymentDate) (wz�r do wyznaczania ustalamy na (1-x)*price) price-koszt bez ustalania daty p�atno�ci, x - liczba dni od konferencji/100

--g) lista dni konkretnej konferencji
create function [FUNC_DaysOfConference] (@ConferenceID int)
	returns table
as 
	return (select DayNumber from ConferenceDays where ConferenceID = @ConferenceID)
end

--h) lista participant�w na konkretny dzie�

create function [FUNC_ParticipantsOnCertainDay] (@DayID int)
	returns table
as
	return 
	(select distinct p.PersonID,p.First_Name,p.Last_Name from ConferenceDayReservation cdr
	join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	join ConferenceParticipant cp on cp.ConferenceParticipantID = cdp.ConferenceParticipantID
	join Person p on p.PersonID = cp.PersonID
	where cdr.ConferenceDayID = @DayID
	)
--i) lista participant�w na konkretn� konferencj�

create function [FUNC_ParticipantsOnCertainConference] (@ConferenceID int)
	returns table
as
	return
	(
	select distinct p.PersonID,p.First_Name,p.Last_Name from ConferenceDays cd
	join ConferenceDayReservation cdr on cdr.ConferenceDayID = cd.ConferenceDayID
	join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	join ConferenceParticipant cp on cp.ConferenceParticipantID = cdp.ConferenceParticipantID
	join Person p on p.PersonID = cp.PersonID
	where cd.ConferenceID = @ConferenceID
	)

--j) lista participant�w na konkretny warsztat

create function [FUNC_ParticipantsOnCertainWorkShop] (@WorkShopID int)
	returns table
as 
	return
	(
	select distinct p.PersonID,p.First_Name,p.Last_Name,p.Phone from  WorkShopReservation wsr
	join WorkShopParticipant wsp on wsr.WorkShopReservationID = wsp.WorkShopReservationID
	join ConferenceParticipant cp on cp.ConferenceParticipantID = wsp.ConferenceParticipantID
	join Person p on p.PersonID = cp.PersonID
	where wsr.WorkShopID = @WorkShopID
	)
--k) lista wszystkich warsztat�w participanta na konkretn� konferencj�

create function [FUNC_WorkShopsOfCertainParticipant] (@ConferenceParticipantID int)
	returns table
as
	return
	(select ws.WorkShopID,ws.WorkShopName from ConferenceParticipant cp
	join WorkShopParticipant wsp on wsp.ConferenceParticipantID = cp.ConferenceParticipantID 
	and cp.ConferenceParticipantID = @ConferenceParticipantID
	join WorkShopReservation wsr on wsr.WorkShopReservationID = wsp.WorkShopReservationID
	join WorkShop ws on ws.WorkShopID = wsr.WorkShopID)

--l)
