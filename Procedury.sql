--PROCEDURY

--a) Wstawienie konferencji

create procedure [PROC_addConference]
	@StartDate date,
	@EndDate date,
	@City char(50),
	@Street char(50)
as
begin
	set nocount on;
	begin try
		
		if exists (select * from Conferences where StartDate = @StartDate and EndDate = @EndDate)
			throw 50003,'Already exist such conference',1

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

--b) 
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
end

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