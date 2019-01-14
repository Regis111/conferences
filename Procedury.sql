--PROCEDURY

--a) dodaje konferencjê

create procedure [PROC_addConference]
	@StartDate date,
	@EndDate date,
	@City char(50),
	@Street char(50)
as
begin
	set nocount on;
	begin try
		
		if exists (select * from Conferences where StartDate = @StartDate and EndDate = @EndDate and @City = City and Street = @Street)
		begin;
			throw 50003,'Already exist such conference',1
		end

		insert into Conferences(
			StartDate,
			EndDate,
			City,
			Street
			)
		values(
			@StartDate,
			@EndDate,
			@City,
			@Street
		)
	end try

	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conference: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--b) dodaje dzieñ do konferencji
create procedure [PROC_AddDayToConference]
	@ConferenceID int,
	@DayNum int,	
	@ConferenceDayID int
as
begin
	set nocount on;
	begin try
		if not exists (select * from Conferences where ConferenceID = @ConferenceID)
		begin;
			throw 50005,'No such conference => cannot add day',1
		end

		if exists (select * from ConferenceDays where DayNumber = @DayNum)
		begin;
			throw 50007,'Already added day',1
		end
		insert into ConferenceDays(
			ConferenceID,
			DayNumber
		)
		values(
			@ConferenceID,
			@DayNum
		)
	end try
	
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceDay: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--c) dodaje rezerwacjê dnia do rezerwacji klienta
create procedure [PROC_AddDayReservation]
	@NormalTicket decimal(10,2),
	@StudentTicket decimal(10,2),
	@ReservationID int,
	@ConferenceDayID int
as
begin
	begin try

		if not exists (select * from Reservations where ReservationID = @ReservationID)
		begin;
			throw 50005,'No such reservation => cannot add day reservation',1
		end 

		if not exists (select * from ConferenceDays where ConferenceDayID = @ConferenceDayID)
		begin;
			throw 50005,'No such conference => cannot add day',1
		end

		if exists (select * from ConferenceDayReservation where ReservationID = @ReservationID and ConferenceDayID = @ConferenceDayID)
		begin;
			throw 50007,'Already added day_reservation',1
		end

		insert into ConferenceDayReservation(
			NormalTicket,
			StudentTicket,
			ConferenceDayID,
			ReservationID
		)
		values(
			@NormalTicket,
			@StudentTicket,
			@ConferenceDayID,
			@ReservationID
		)

	end try

	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceDay: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end
--d) dodaje rezerwacjê na konferencjê

create procedure [PROC_AddReservation]
	@ReservationDate date,
	@CustomerID int,
	@ConferenceID int,
	@PaymentDate date
as
begin
	begin try
		if not exists (select * from Customers where CustomerID = @CustomerID)
		begin;
			throw 50005,'No such reservation => cannot add day reservation',1
		end 

		if not exists (select * from Conferences where ConferenceID = @ConferenceID)
		begin;
			throw 50005,'No such conference => cannot add day',1
		end

		if exists (select * from Reservations where CustomerID = @CustomerID and ConferenceID = @ConferenceID)
		begin;
			throw 50007,'Already added day_reservation',1
		end

		insert into Reservations(
			ReservationDate,
			CustomerID,
			ConferenceID,
			PaymentDate
		)
		values(
			@ReservationDate,
			@CustomerID,
			@ConferenceID,
			@PaymentDate
		)
	end try

	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this Reservation: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--e) dodaje warsztat do dnia konferencji

--f) dodaje klienta firmowego

--g) dodaje pracownika firmy

--h) dodaje uczestnika do konferencji z konkretnej rezerwacji (wiadomo na jakie dni go dodaæ) + informacja czy jest studentem

--i) dodaje uczestnika na warsztat (sprawdza czy nie bêdzie na dwóch jednoczeœnie)
 --(dodaje do WorkShopReservation i do WorkShopParticipant) 

--j) dodaje klienta indywidualnego

--INNE

--a) p³aci za rezerwacjê

--b) usuwa rezerwacjê jeœli nie op³acona na tydzieñ przed konferencj¹

--c)





















declare @s date 
set @s = '2008-01-01'

declare @e date
set @e = '2008-01-06'

declare @city char(50)
set @city = 'Reda'

declare @street char(50)
set @street = 'Pucka'

exec PROC_addConference @s,@e,@city,@street

select * from Conferences

DBCC CHECKIDENT ('Conferences', RESEED, 4)
GO