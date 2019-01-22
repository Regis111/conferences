--TRIGGERY

--1)Blokuje rezerwację na dzień konferencji, jeżeli nie ma miejsc
CREATE TRIGGER [TRIG_NoFreePlacesForConferentionDay]
 ON ConferenceDayReservation
 AFTER INSERT
 AS
 BEGIN
 IF EXISTS
 (
 SELECT * FROM inserted AS i
 WHERE ( dbo.FUNC_PaidReservations(i.ConferenceDayReservationID )+dbo.FUNC_UnpaidReservations(i.ConferenceDayReservationID)>=
 dbo.func_ConferenceDaySeatsLimit(i.ConferenceDayID)
 )
 )
 BEGIN
 ; THROW 50001 , 'No places left.' ,1
 END
 END
 GO

--2)Blokuje rezerwację na warsztat, jeżeli nie ma miejsc
CREATE TRIGGER [TRIG_NoFreePlacesForWorkshop]
 ON Workshop
 AFTER INSERT
 AS
 BEGIN
 IF EXISTS
 (
 SELECT * FROM inserted AS i
 WHERE ( dbo.FUNC_WorkshopBookedSeats(i.WorkShopID)>=dbo.func_WorkshopSeatsLimit(i.WorkShopID)
 )
 )
 BEGIN
 ; THROW 50001 , 'No places left.' ,1
 END
 END
 GO

--3)Usuwa rezerwację wraz z wszystkimi jej członkami gdy nie zostanie uiszczona wpłata tydzień przed konferencję


--4)Blokuje możliwość rezerwowania jeżeli jest mniej niż tydzień do rezerwacji ok
	CREATE TRIGGER [TRIG_7DaysTillConferenceCheck]
	 ON Reservations
	AFTER INSERT
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 join Conferences as c
	 on c.ConferenceID=i.ConferenceID
	 where DATEDIFF(day,getdate(),c.StartDate)<7
	 )
	 BEGIN
	 ; THROW 50001 , 'Too late!!!' ,1
	 END
	 END
	 GO

--5)Blokuje dodawanie dnia konferencji jeżeli wykracza poza czas trwania konferencji ok
CREATE TRIGGER [TRIG_DaysAfterConferenceBlock]
	 ON ConferenceDays
	AFTER INSERT
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 join Conferences as c
	 on c.ConferenceID=i.ConferenceID
	 where DATEADD(day,i.DayNumber-1,c.StartDate)>c.EndDate
	 )
	 BEGIN
	 ; THROW 50001 , 'That day is not in the bounds of conference' ,1
	 END
	 END
	 GO

--6)Pilnuje, czy po zmianie ilości zarezerwowanych miejsc na dany dzień zmieniona ilość obejmuje wszystkie zapisane osoby 


--7)Usuwanie wszystkich rezerwacji dni po usunięciu danej rezerwacji ok
CREATE TRIGGER [TRIG_DeleteReservationDaysAfterDeletingReservation]
 ON Reservations
 AFTER DELETE
 AS
 BEGIN
 SET NOCOUNT ON;
 DELETE FROM ConferenceDayReservation
 WHERE ReservationID IN
 (
 SELECT rw.ReservationID
 FROM deleted AS d
 JOIN ConferenceDayReservation AS rw
 ON rw.ReservationID = d.ReservationID
 )
 END
 GO


--8)Usuwanie wszystkich ConferenceDayParticipant po usunięciu danej rezerwacji dnia ok
 CREATE TRIGGER [TRIG_DeleteConferenceDayParticipantAfterDeletingReservationDay]
 ON ConferenceDayReservation
 AFTER DELETE
 AS
 BEGIN
 SET NOCOUNT ON;
 DELETE FROM ConferenceDayParticipant
 WHERE ConferenceDayReservationID IN
 (
 SELECT rw.ConferenceDayReservationID
 FROM deleted AS d
 JOIN ConferenceDayParticipant AS rw
 ON rw.ConferenceDayReservationID = d.ConferenceDayReservationID
 )
 END
 GO


--9)Usuwanie wszystkich WorkShopParticipant po usunięciu ConferenceDayParticipant ok
 CREATE TRIGGER [TRIG_DeleteWorkShopParticipantsAfterDeletingConferenceDayParticipant]
 ON ConferenceDayParticipant
 AFTER DELETE
 AS
 BEGIN
 SET NOCOUNT ON;
 DELETE FROM WorkShopParticipant
 WHERE ConferenceParticipantID IN
 (
 SELECT d.ConferenceParticipantID
 FROM deleted AS d
 join ConferenceDayReservation as cdr
 on d.ConferenceDayReservationID = cdr.ConferenceDayReservationID
 join ConferenceDays as cd
 on cd.ConferenceDayID=cdr.ConferenceDayID
 join WorkShop as ws 
 on ws.ConferenceDayID=cd.ConferenceDayID
 join WorkShopReservation as wsr
 on wsr.WorkShopID=ws.WorkShopID
 join WorkShopParticipant as wsp
 on wsp.WorkShopReservationID=wsr.WorkShopReservationID
 )
 END
 GO

--10)Usuwanie wszystkich rezerwacji warsztatów po usunięciu danej rezerwacji dnia ok


--11)Sprawdzanie czy limit miejsc warsztatów jest większy od limitu dnia konferencji (nie może być)
	CREATE TRIGGER [TRIG_ConferenceLimitVsWorkshopLimit]
	 ON ConferenceDays
	AFTER INSERT, UPDATE
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 join WorkShop as w on w.ConferenceDayID=i.ConferenceDayID
	 where i.SeatsLimit<w.SeatsLimit
	 )
	 BEGIN
	 ; THROW 50001 , 'Workshop cannot have highter limit than conference' ,1
	 END
	 END
	 GO

--12) Sprawdzanie czy ilość rezerwacji na warsztat nie jest większa od ilości rezerwacji na konferencję
CREATE TRIGGER [TRIG_ConferenceReservVsWorkshopReserv]
	 ON ConferenceDays
	AFTER INSERT, UPDATE
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 join WorkShop as w on w.ConferenceDayID=i.ConferenceDayID
	 where dbo.FUNC_WorkshopBookedSeats(w.WorkShopID)>dbo.FUNC_PaidReservations(i.ConferenceDayID )+dbo.FUNC_UnpaidReservations(i.ConferenceDayID)
	 )
	 BEGIN
	 ; THROW 50001 , 'Workshop cannot have more reservations than conference' ,1
	 END
	 END
	 GO

--13) Sprawdzenie przekroczenia 7 dni na zapłatę
CREATE TRIGGER [TRIG_7DaysDelayCheck]
	 ON Reservations
	AFTER INSERT, UPDATE
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 where DATEDIFF(day,i.ReservationDate,getdate())>7
	 )
	 BEGIN
	 ; THROW 50001 , 'Too late!!!' ,1
	 END
	 END
	 GO

--14) Sprawdzanie czy data rozpoczęcia konferencji jest przed datą zakończenia konferencji
CREATE TRIGGER [TRIG_ConferenceDatesCheck]
	 ON Conferences
	AFTER INSERT
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 where DATEDIFF(day,i.StartDate,i.EndDate)<0
	 )
	 BEGIN
	 ; THROW 50001 , 'Start date should be before End date!' ,1
	 END
	 END
	 GO

--15)Sprawdzanie czy data rozpoczęcia warsztatu jest przed datą zakończenia warsztatu
CREATE TRIGGER [TRIG_WorkshopTimeCheck]
	 ON WorkShop
	AFTER INSERT
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 where DATEDIFF(hour,i.StartTime,i.EndTime)<0
	 )
	 BEGIN
	 ; THROW 50001 , 'Start time should be before End time!' ,1
	 END
	 END
	 GO

--16) Sprawdzanie czy data rozpoczęcia konferencji jest w przyszłości
CREATE TRIGGER [TRIG_IsStartDateInFuture]
	 ON Conferences
	AFTER INSERT
	AS
	BEGIN
	 IF EXISTS
	 (
	 SELECT * FROM inserted AS i
	 where DATEDIFF(day,getdate(),i.StartDate)<0
	 )
	 BEGIN
	 ; THROW 50001 , 'Not in future!' ,1
	 END
	 END
	 GO
