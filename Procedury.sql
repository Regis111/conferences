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

--e) dodaje rezerwacjê dnia do rezerwacji
create procedure [PROC_AddDayReservation]
	@NormalTickets int = 0,
	@StudentTickets int = 0,
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
			NormalTickets,
			StudentTickets,
			ConferenceDayID,
			ReservationID
		)
		values(
			@NormalTickets,
			@StudentTickets,
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
create procedure [PROC_AddWorkShopReservation]
	@WorkShopID int,
	@ConferenceDayReservationID int,
	@NormalTickets int = 0,
	@StudentTickets int = 0
as
begin
	begin try
		if not exists (select * from ConferenceDayReservation where ConferenceDayReservationID = @ConferenceDayReservationID)
		begin;
			throw 50005,'No such conference => cannot add day',1
		end

		if not exists (select * from WorkShop where WorkShopID = @WorkShopID)
		begin;
			throw 50005,'No such conference => cannot add day',1
		end

		insert WorkShopReservation(
			NormalTickets,
			StudentTickets,
			WorkShopID,
			ReservationDayID
		)
		values(
			@NormalTickets,
			@StudentTickets,
			@WorkShopID,
			@ConferenceDayReservationID
		)
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceDay: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--g) dodaje klienta firmowego

create procedure [PROC_AddCompanyCustomer]
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
create procedure [PROC_AddEmployee]
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
end

--l) dodanie cz³owieka (person) do systemu

create procedure [PROC_addPerson]
	@FirstName char(255),
	@LastName char(255),
	@Phone varchar(50)
as
begin
	begin try
		if not exists (select * from Person where @FirstName = First_Name and @LastName = Last_Name)
		begin;
			throw 50005,'No such company => cannot add day reservation',1
		end 

		insert Person(
			First_Name,
			Last_Name,
			Phone
		)
		values(
		@FirstName,
		@LastName,
		@Phone
		)
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--k) dodaje klienta indywidualnego

create procedure [PROC_addIndividualClient]
	@Email char(255),
	@PhoneNumber char(50),
	@Street char(255),
	@PostalCode char(255),
	@PersonID int
as
begin
	begin try
		if not exists (select * from Person where PersonID = @PersonID)
		begin;
			throw 50005,'No such company => cannot add day reservation',1
		end 
		insert Customers(
			Email,
			PhoneNumber,
			Street,
			PostalCode
		)
		values(
			@Email,
			@PhoneNumber,
			@Street,
			@PostalCode
		)
		insert IndividualClient(
			CustomerID,
			PersonID
		)
		values(
			SCOPE_IDENTITY(),
			@PersonID
		)
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--i) dodaje uczestnika do konferencji do konkretnej rezerwacji dnia + informacja czy jest studentem

create procedure [PROC_addConferenceParticipant]
	@PersonID int,
	@ConferenceDayReservationID int,
	@StudentCard int
as
begin
	begin try

		if not exists (select * from ConferenceDayReservation where ConferenceDayReservationID = @ConferenceDayReservationID)
		begin;
			throw 50005,'No such company => cannot add day reservation',1
		end 

		if not exists (select * from Person where PersonID = @PersonID)
		begin;
			throw 50005,'No such Person => cannot add day',1
		end

		if exists (select * from ConferenceParticipant cp 
		join ConferenceDayParticipant cdp on cp.ConferenceParticipantID = cdp.ConferenceParticipantID
		where cp.PersonID = @PersonID and cdp.ConferenceDayReservationID = @ConferenceDayReservationID)
		begin;
			throw 50007,'Already added day_reservation',1
		end

		insert ConferenceParticipant(PersonID) values(@PersonID)

		insert ConferenceDayParticipant(
		ConferenceParticipantID,
		ConferenceDayReservationID
		)
		values(
		SCOPE_IDENTITY(),
		@ConferenceDayReservationID
		)
		if @StudentCard is not null
		begin;
			insert Student(
			StudentCardID,
			ConferenceParticipantID
			)
			values(
			@StudentCard,
			SCOPE_IDENTITY()
			)
		end

	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--j) dodaje uczestnika na rezerwacjê warsztatu (sprawdza czy nie bêdzie na dwóch jednoczeœnie)

create procedure [PROC_addWorkShopParticipant]
	@ConferenceParticipantID int,
	@WorkShopReservationID int
as
begin
	begin try
		if not exists (select * from ConferenceParticipant where ConferenceParticipantID = @ConferenceParticipantID)
		begin;
			throw 50005,'No such company => cannot add day reservation',1
		end 

		if not exists (select * from WorkShopReservation where WorkShopReservationID = @WorkShopReservationID)
		begin;
			throw 50005,'No such Person => cannot add day',1
		end

		declare @WorkShopID int = (select WorkShopID from WorkShopReservation where WorkShopReservationID = @WorkShopReservationID)

		if ((select COUNT(ConferenceParticipantID) from WorkShopParticipant wsp
		join WorkShopReservation wsr on wsr.WorkShopReservationID = wsp.WorkShopReservationID
		where ConferenceParticipantID = @ConferenceParticipantID 
		and dbo.FUNC_AreTheseWorkShopsAtTheSameTime(@WorkShopID, wsr.WorkShopID) = 0) > 0)
		begin;
			throw 50005,'No such Person => cannot add day',1
		end

		insert WorkShopParticipant(
		ConferenceParticipantID,
		WorkShopReservationID
		)
		values(
		@ConferenceParticipantID,
		@WorkShopReservationID
		)
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--INNE

--a) p³aci za rezerwacjê
create procedure [FUNC_PayForReservation]
	@ReservationID int,
	@PaymentDate date
as
begin
	update Reservations
	set PaymentDate = @PaymentDate
	where ReservationID = @ReservationID
end

--USUWANIE

--a) usuwa rezerwacjê

--b) usuwa rezerwacjê na dzieñ

--c) usuwa rezerwacjê na warsztat

--d) usuwa uczestnika z warsztatu

--e) usuwa uczestnika z dnia


