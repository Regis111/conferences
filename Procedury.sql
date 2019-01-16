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
	@DayNum int
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

--c) dodaje warsztat do dnia konferencji
create procedure [PROC_AddWorkShop]
	@WorkShopName char(255),
	@SeatsLimit int,
	@ConferenceDayID int,
	@StartTime time,
	@EndTime time
as
begin
	begin try
		if not exists (select * from ConferenceDays where ConferenceDayID = @ConferenceDayID)
		begin;
			throw 50005,'No such day => cannot add workshop',1
		end

		if exists (select * from WorkShop where ConferenceDayID = @ConferenceDayID and @WorkShopName = WorkShopName)
		begin;
			throw 50005,'Already added such WorkShop',1
		end
		insert into WorkShop(
			WorkShopName,
			SeatsLimit,
			ConferenceDayID,
			StartTime,
			EndTime
		)
		values(
			@WorkShopName,
			@SeatsLimit,
			@ConferenceDayID,
			@StartTime,
			@EndTime
		)
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this WorkShop: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--d) dodaje rezerwacjê na konferencjê

create procedure [PROC_AddReservation]
	@CustomerID int,
	@ConferenceID int,
	@PaymentDate date
as
begin
	begin try
		if not exists (select * from Customers where CustomerID = @CustomerID)
		begin;
			throw 50005,'No such customer => cannot add reservation',1
		end 

		if not exists (select * from Conferences where ConferenceID = @ConferenceID)
		begin;
			throw 50005,'No such conference => cannot add reservation',1
		end

		if exists (select * from Reservations where CustomerID = @CustomerID and ConferenceID = @ConferenceID)
		begin;
			throw 50007,'Already added reservation',1
		end

		insert into Reservations(
			ReservationDate,
			CustomerID,
			ConferenceID,
			PaymentDate
		)
		values(
			getdate(),
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

--e) dodaje rezerwacjê dnia do rezerwacji klienta
create procedure [PROC_AddDayReservation]
	@NormalTickets int = 0,
	@StudentTicket int = 0,
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

-- f) dodaje rezerwacjê warsztatu do rezerwacji dnia

--g) dodaje klienta firmowego
create procedure [AddCompanyCustomer]
	@Company char(255),
	@PhoneNumber int,
	@Street char(255),
	@PostalCode char(255)
as
begin
	begin try
		begin transaction
			insert into Customers(
			PhoneNumber,
			Street,
			PostalCode
			)
			values(
				@PhoneNumber,
				@Street,
				@PostalCode
			)
			insert into Company(
				Company,
				CustomerID
			)
			values(
				@Company,
				SCOPE_IDENTITY()
			)
		commit transaction
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this Customer or Company: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--h) dodaje pracownika firmy
create procedure [FUNC_AddEmployee]
	@CompanyID int,
	@PersonID int
as
begin
	
	begin try

		if not exists (select * from Company where CompanyID = @CompanyID)
		begin;
			throw 50005,'No such company => cannot add day reservation',1
		end 

		if not exists (select * from Person where PersonID = @PersonID)
		begin;
			throw 50005,'No such conference => cannot add day',1
		end

		if exists (select * from Employees where PersonID = @PersonID and CompanyID = @CompanyID)
		begin;
			throw 50007,'Already added day_reservation',1
		end

		insert into Employees(
			CompanyID,
			PersonID
		)
		values(
			@CompanyID,
			@PersonID
		)
	end try

	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceDay: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
--i) dodaje uczestnika do konferencji z konkretnej rezerwacji (wiadomo na jakie dni go dodaæ) + informacja czy jest studentem

--j) dodaje uczestnika na warsztat (sprawdza czy nie bêdzie na dwóch jednoczeœnie)
 --(dodaje do WorkShopReservation i do WorkShopParticipant) 

--k) dodaje klienta indywidualnego

--l) dodanie cz³owieka (person) do systemu

--m) dodaje osobê do konkretnej konferecji

--n) dodaje osobê do konkretnej rezerwacji dnia

--o) dodaje osobê do konkretnej rezerwacji warsztatu

--INNE

--a) p³aci za rezerwacjê



--b) usuwa rezerwacjê jeœli nie op³acona na tydzieñ przed konferencj¹

--c)






--koniec implementacji

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