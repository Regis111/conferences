--Funkcje

--1)zarobek za jedn¹ konferencjê z samych warsztatów
 create function [FUNC_WorkshopIncomeFromOneConference] (@ConferenceID int)
	returns money
as
begin

if not exists (select * from Conferences where ConferenceID = @ConferenceID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN ISNULL((SELECT SUM(wr.NormalTickets*ws.price) + SUM(wr.StudentTickets*ws.price*0.5)
	
FROM WorkShopReservation as wr
join WorkShop as ws
on ws.WorkShopID=wr.WorkShopID
join ConferenceDays as cd
on cd.ConferenceDayID = ws.ConferenceDayID
join Conferences as co
on co.ConferenceID = cd.ConferenceID
Where co.ConferenceID = @ConferenceID),
0)
end

--2)  iloœæ wolnych miejsc na konkretny dzieñ (suma wolnych miejsc na wszystkich warsztatach na ten dzieñ)

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

--3) czy dwa warsztaty s¹ w tym samym czasie 

drop function dbo.FUNC_AreTheseWorkShopsAtTheSameTime

create function [FUNC_AreTheseWorkShopsAtTheSameTime] (@WorkShop1ID int, @WorkShop2ID int)
	returns bit
as
begin
	if not exists (select * from WorkShop where WorkShopID = @WorkShop1ID) or not exists (select * from WorkShop where WorkShopID = @WorkShop2ID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	declare @start1 time = (select StartTime from WorkShop where WorkShopID = @WorkShop1ID)
	declare @end1 time = (select EndTime from WorkShop where WorkShopID = @WorkShop1ID)
	declare @start2 time = (select StartTime from WorkShop where WorkShopID = @WorkShop2ID)
	declare @end2 time = (select EndTime from WorkShop where WorkShopID = @WorkShop2ID)
	
	if @start1 < @start2 and @start2 < @end1
		return 0
	
	if @start2 < @start1 and @start1 < @end2
		return 0

	if @start1 <= @start2 and @end1 >= @end2
		return 0

	if @start2 <= @start1 and @end2 >= @end1
		return 0

	return 1
end

--4) iloœæ wolnych miejsc na konkretny warsztat

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

--5) koszt konkretnej rezerwacji (na podstawie paymentDate) (wzór do wyznaczania ustalamy na (1-x)*price) price-koszt bez ustalania daty p³atnoœci, x - liczba dni od konferencji/100

--6) lista dni konkretnej konferencji
create function [FUNC_DaysOfConference] (@ConferenceID int)
	returns table
as 
	return (select DayNumber from ConferenceDays where ConferenceID = @ConferenceID)
end

--7) lista participantów na konkretny dzieñ

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
--8) lista participantów na konkretn¹ konferencjê

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

--9) lista participantów na konkretny warsztat

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
--10) lista wszystkich warsztatów participanta na konkretn¹ konferencjê

create function [FUNC_WorkShopsOfCertainParticipant] (@ConferenceParticipantID int)
	returns table
as
	return
	(select ws.WorkShopID,ws.WorkShopName from ConferenceParticipant cp
	join WorkShopParticipant wsp on wsp.ConferenceParticipantID = cp.ConferenceParticipantID 
	and cp.ConferenceParticipantID = @ConferenceParticipantID
	join WorkShopReservation wsr on wsr.WorkShopReservationID = wsp.WorkShopReservationID
	join WorkShop ws on ws.WorkShopID = wsr.WorkShopID)

--11)Cena noemalnego biletu dla danego warsztatu
create function [FUNC_NormalTicketPrice] (@WorkshopID int)
	returns money
as
begin
if not exists (select * from WorkShop where WorkShopID = @WorkshopID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select price from WorkShop
	where WorkShopID=@WorkshopID
	)
end


--12)Cena studenckiego biletu dla danego warsztatu (przelicznik 0,5*cena normalna)
create function [FUNC_StudentTicketPrice] (@WorkshopID int)
	returns money
as
begin
if not exists (select * from WorkShop where WorkShopID = @WorkshopID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select (0.5*price)
	 from WorkShop
	where WorkShopID=@WorkshopID
	)
end
--13)ID dnia konferencji na podstawie daty i conferenceID
create function [FUNC_ConferenceDayBasedOnDate] (@ConferenceID int,@date date)
	returns money
as
begin
if not exists (select * from Conferences where ConferenceID = @ConferenceID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select cd.ConferenceID 
	from ConferenceDays as cd
	join Conferences as co
	on co.ConferenceID = cd.ConferenceID
	where (DATEDIFF(dd, @ConferenceID, co.StartDate) =cd.DayNumber

	))
end

--14)Limit miejsc Workshopu
create function [FUNC_WorkshopSeatsLimit] (@WorkshopID int)
	returns int
as
begin
if not exists (select * from WorkShop where WorkShopID = @WorkshopID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select SeatsLimit from WorkShop
	where WorkShopID=@WorkshopID
	)
end


--15)ilość zarezerwowanych miejsc na warsztat

create function [FUNC_WorkshopBookedSeats] (@WorkshopID int)
	returns int
as
begin
if not exists (select * from WorkShop where WorkShopID = @WorkshopID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select sum(wr.NormalTickets)+sum(wr.StudentTickets) 
	from WorkShop as ws 
	join WorkShopReservation as wr
	on wr.WorkShopID=ws.WorkShopID
	where ws.WorkShopID=@WorkshopID
	)
end

--16)ilość wolnych miejsc na warsztat
create function [FUNC_WorkshopFreeSeats] (@WorkshopID int)
	returns int
as
begin
if not exists (select * from WorkShop where WorkShopID = @WorkshopID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select SeatsLimit - dbo.FUNC_WorkshopBookedSeats(@WorkshopID)
	from WorkShop
	)
end
--17)ilość opłaconych miejsc na konferencję
create function [FUNC_PaidReservations] (@ConferenceID int)
	returns int
as
begin
if not exists (select * from Conferences where ConferenceID = @ConferenceID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select count(r.ConferenceID) 
	from Reservations as r
	join Conferences as c
	on c.ConferenceID=r.ConferenceID
	where r.PaymentDate is not null and c.ConferenceID = @ConferenceID

	)
end

--18)ilość zarezerwowanych miejsc na konferencję (nieopłaconych)
create function [FUNC_UnpaidReservations] (@ConferenceID int)
	returns int
as
begin
if not exists (select * from Conferences where ConferenceID = @ConferenceID)
	begin;
		return cast('Error happened here.' as int);
	end
	
	RETURN (
	select count(r.ConferenceID) 
	from Reservations as r
	join Conferences as c
	on c.ConferenceID=r.ConferenceID
	where r.PaymentDate is null and c.ConferenceID = @ConferenceID

	)
end

