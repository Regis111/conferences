--PROCEDURY

--a) dodaje konferencjê
drop procedure  [addConference]
create procedure [AddConference]
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
create procedure [AddDayToConference]
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

drop procedure [PROC_AddWorkShop]
--c) dodaje warsztat do dnia konferencji
create procedure [AddWorkShop]
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
drop procedure [PROC_AddReservation]

create procedure [AddReservation]
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

drop procedure [PROC_AddDayReservation]
--e) dodaje rezerwacjê dnia do rezerwacji
create procedure AddDayReservation
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

drop procedure PROC_AddWorkShopReservation

-- f) dodaje rezerwacjê warsztatu do rezerwacji dnia

create procedure AddWorkShopReservation
	@WorkShopID int,
	@ConferenceDayReservationID int,
	@NormalTickets int ,
	@StudentTickets int
as
begin
	begin try
		if not exists (select * from ConferenceDayReservation where ConferenceDayReservationID = @ConferenceDayReservationID)
		begin;
			throw 50005,'No such ConferenceDayReservation => cannot add day',1
		end

		if not exists (select * from WorkShop where WorkShopID = @WorkShopID)
		begin;
			throw 50005,'No such WorkSHop => cannot add day',1
		end

		if exists (select  * from WorkShopReservation wsr where wsr.ReservationDayID = @ConferenceDayReservationID and wsr.WorkShopID =@WorkShopID)
		begin;
			throw 50005,'Already exist such ConferenceDayReservatoin => cannot add day',1
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

create procedure AddCompanyCustomer
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
create procedure AddEmployee
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

drop procedure addPerson

create procedure AddPerson
	@FirstName char(255),
	@LastName char(255),
	@Phone varchar(50)
as
begin
	begin try
		if exists (select * from Person where @FirstName = First_Name and @LastName = Last_Name)
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
drop procedure AddIndividualClient

create procedure AddIndividualClient
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

drop procedure addConferenceDayParticipant

create procedure AddConferenceDayParticipant
	@PersonID int,
	@ConferenceDayReservationID int,
	@StudentCard int
as
begin
	begin try
		if not exists (select * from ConferenceDayReservation where ConferenceDayReservationID = @ConferenceDayReservationID)
		begin;
			throw 50005,'No such DayReservation => cannot add conference participant',1
		end 

		if not exists (select * from Person where PersonID = @PersonID)
		begin;
			throw 50005,'No such Person => cannot add conference participant',1
		end

		if exists (select * from ConferenceParticipant cp 
		join ConferenceDayParticipant cdp on cp.ConferenceParticipantID = cdp.ConferenceParticipantID
		where cp.PersonID = @PersonID and cdp.ConferenceDayReservationID = @ConferenceDayReservationID)
		begin;
			throw 50007,'Already added ConferenceParticipant',1
		end

		declare @CompanyID int = (select CompanyID from Reservations r
								join Customers c on c.CustomerID = r.ConferenceID
								join Company cy on cy.CustomerID = c.CustomerID)

		if not exists (select * from Employees where PersonID = @PersonID and CompanyID = @CompanyID)
		begin;
			throw 50007,'Cant Person to dayReservation because he isnt Employee of this Company',1	
		end

		declare @ConferenceID int = (select ConferenceID from ConferenceDays cd
								join ConferenceDayReservation cdr on cd.ConferenceDayID = cdr.ConferenceDayID
								where cdr.ConferenceDayReservationID = @ConferenceDayReservationID)

		if not exists (select * from ConferenceParticipant cp
		join ConferenceDayParticipant cdp on cdp.ConferenceParticipantID = cp.ConferenceParticipantID
		join ConferenceDayReservation cdr on cdr.ConferenceDayReservationID = cdp.ConferenceDayReservationID
		join ConferenceDays cd on cd.ConferenceDayID = cdr.ConferenceDayID and cd.ConferenceID = @ConferenceID 
		where cp.PersonID = @PersonID)
		begin;

		insert ConferenceParticipant(PersonID) values(@PersonID)
		
		end

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
				update ConferenceDayReservation
				set StudentTickets = StudentTickets + 1
				where ConferenceDayReservationID = @ConferenceDayReservationID
			end
		else
			begin;
				update ConferenceDayReservation
				set NormalTickets = NormalTickets + 1
				where ConferenceDayReservationID = @ConferenceDayReservationID
			end
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt add this conferenceParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--j) dodaje uczestnika (który jest ju¿ ConferenceParticipant i ConferenceDayParticipant) na rezerwacjê warsztatu (sprawdza czy nie bêdzie na dwóch jednoczeœnie)

drop procedure addWorkShopParticipant

create procedure AddWorkShopParticipant
	@ConferenceParticipantID int,
	@WorkShopReservationID int
as
begin
	begin try
		if not exists (select * from ConferenceParticipant where ConferenceParticipantID = @ConferenceParticipantID)
		begin;
			throw 50005,'No such company => cannot add day reservation',1
		end 

		if not exists (select * from WorkShopReservation wsr
						join ConferenceDayReservation cdr on cdr.ConferenceDayReservationID = wsr.ReservationDayID
						join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
						where cdp.ConferenceParticipantID = @ConferenceParticipantID)
		begin;
			throw 50005,'ConferenceParticipant cant be added to WorkShopReservation
			 because he isnt ConferenceDayParticipant on that day1',1
		end

		if not exists (select * from WorkShopReservation where WorkShopReservationID = @WorkShopReservationID)
		begin;
			throw 50005,'No such WorkShopReservation => cannot add day',1
		end

		declare @WorkShopID int = (select WorkShopID from WorkShopReservation where WorkShopReservationID = @WorkShopReservationID)

		if ((select COUNT(ConferenceParticipantID) from WorkShopParticipant wsp
		join WorkShopReservation wsr on wsr.WorkShopReservationID = wsp.WorkShopReservationID
		where ConferenceParticipantID = @ConferenceParticipantID 
		and dbo.FUNC_AreTheseWorkShopsAtTheSameTime(@WorkShopID, wsr.WorkShopID) = 0) > 0)
		begin;
			throw 50005,'WorkShops are overlapping',1
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
drop procedure PROC_PayForReservation

create procedure PayForReservation
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
--create procedure [FUNC_deleteReservation]

--b) usuwa rezerwacjê na dzieñ TO DO
create procedure [FUNC_deleteConferenceDayReservation]
	@DayReservationID int
as 
begin
	begin try
		if not exists (select * from ConferenceDayReservation where ConferenceDayReservationID = @DayReservationID)
			throw 50005,'No such WorkShopReservation',1

		--exec [FUNC_deleteWorkShopReservation] (select WorkShopReservationID from WorkShopReservation where ReservationDayID = @DayReservationID)

		delete from ConferenceDayReservation
		where ConferenceDayReservationID = @DayReservationID
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt delete this ConferenceDayReservation:' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--c) usuwa rezerwacjê na warsztat

create procedure [FUNC_deleteWorkShopReservation]
	@WorkShopReservationID int
as
begin
	begin try
		if not exists (select * from WorkShopReservation where WorkShopReservationID = @WorkShopReservationID)
			throw 50005,'No such WorkShopReservation',1

		delete from WorkShopParticipant
		where WorkShopReservationID = @WorkShopReservationID

		delete from WorkShopReservation
		where WorkShopReservationID = @WorkShopReservationID

	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt delete this WorkShopReservation: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end


--d) usuwa uczestnika z warsztatu

create procedure [PROC_deleteWorkShopParticipant]
	@ConferenceParticipantID int,
	@WorkShopReservationID int
as
begin
	begin try
		if not exists (select * from WorkShopReservation where WorkShopReservationID = @WorkShopReservationID)
			throw 50005,'No such WorkShopReservation',1

		if not exists (select * from ConferenceParticipant where ConferenceParticipantID = @ConferenceParticipantID)
			throw 50005,'No such ConferenceParticipant',1

		delete from WorkShopParticipant
		where ConferenceParticipantID = @ConferenceParticipantID
		and WorkShopReservationID = @WorkShopReservationID

		if exists (select * from Student where ConferenceParticipantID = @ConferenceParticipantID)
			begin;
			update WorkShopReservation
			set StudentTickets = StudentTickets - 1
			where WorkShopReservationID = @WorkShopReservationID
			end
		else
			begin;
			update WorkShopReservation
			set NormalTickets = NormalTickets - 1
			where WorkShopReservationID = @WorkShopReservationID
			end

	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt delete this WorkShopParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

--e) usuwa uczestnika z rezerwacji dnia TO DO
create procedure [PROC_deleteConferenceDayParticipant]
	@ConferenceDayReservationID int,
	@ConferenceParticipantID int
as
begin
	begin try
		
		declare @WorkShopReservationID int

		declare the_cursor cursor fast_forward
		for  (select WorkShopReservationID from WorkShopReservation wsr
			join ConferenceDayReservation cdr on cdr.ConferenceDayReservationID = wsr.ReservationDayID
			and cdr.ConferenceDayReservationID = @ConferenceDayReservationID)

		open the_cursor
		fetch next from the_cursor into @WorkShopReservationID

		while @@FETCH_STATUS = 0
		begin
			exec PROC_deleteWorkShopParticipant @ConferenceParticipantID , @WorkShopReservationID
			fetch next from the_cursor into @oneid
		end

		close the_cursor
		deallocate the_cursor

		delete from ConferenceDayParticipant
		where ConferenceParticipantID = @ConferenceParticipantID and ConferenceDayReservationID = @ConferenceDayReservationID
	end try
	begin catch
		declare @message nvarchar(3000) = 'Couldnt delete this WorkShopParticipant: ' + ERROR_MESSAGE();
		throw 60000,@message,1;
	end catch
end

