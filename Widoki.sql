--WIDOKI

--1a) wszystkie warsztaty z informacj¹ o dniu, konferencji i liczbie osób

create view [WorkShopInformation] as
select cd.ConferenceID,cd.DayNumber,ws.WorkShopName,ws.SeatsLimit as max_number_of_people,ws.ReservedSeats as number_of_people_reserved
from ConferenceDays cd
join WorkShop ws on cd.ConferenceDayID = ws.ConferenceDayID

--1b) 20 najbardziej aktywnych klientów

create view [SortedCustomers] as
select top 20 c.CustomerID, count(r.ReservationID) as number_of_reservations
from Customers c
join Reservations r on r.CustomerID = c.CustomerID
group by c.CustomerID
order by number_of_reservations desc 

--1c) nieop³acone rezerwacje indywidualanych klientów

create view [UnPaidReservationsOfIndividualClients] as
select c.CustomerID,cp.First_Name,cp.Last_Name,r.ReservationID from Reservations r
join Customers c on r.CustomerID = c.CustomerID
join IndividualClient i on i.CustomerID = c.CustomerID
join ConferenceParticipant cp on cp.ConferenceParticipantID = i.ConferenceParticipantID
where r.PaymentDate is null

--1d) nieop³acone rezerwacje firm

create view [UnPaidReservationsOfClients] as
select cu.CustomerID,cp.First_Name,cp.Last_Name,r.ReservationID from Reservations r
join Customers cu on r.CustomerID = cu.CustomerID
join Company co on co.CustomerID = cu.CustomerID
join Employees e on e.CompanyID = co.CompanyID
join ConferenceParticipant cp on cp.ConferenceParticipantID = e.ConferenceParticipantID
where r.PaymentDate is null

--1e) warsztaty na które zosta³y wolne miejsca

create view [AvailableWorkShops] as
select cd.ConferenceID,cd.ConferenceDayID,cd.DayNumber,w.WorkShopID,w.WorkShopName from ConferenceDays cd
join WorkShop w on cd.ConferenceDayID = w.ConferenceDayID
where (w.SeatsLimit - w.ReservedSeats) > 0

--1f) rezerwacje które maj¹ byæ op³acone do jutra

create view [ReservationsGettingCanceledTommorrow] as
select * from Reservations r
join Conferences c on c.ConferenceID = r.ConferenceID
where DATEDIFF(dd,GETDATE(), c.StartDate) = 8

--1g) iloœæ rezerwacji na konferencje

create view [NumberOfReservationsOnConference] as
select c.ConferenceID, count(r.ReservationID) as [liczba rezerwacji] from Conferences c
join Reservations r on r.ConferenceID = c.ConferenceID
group by c.ConferenceID

--1h)  konferencje z iloœci¹ zarezerwowanych miejsc na ka¿dy

create view [NumberOfReservedSeatsForConference] as
select c.ConferenceID,(select COUNT(cdp.ConferenceParticipantID)) from Conferences c
join ConferenceDays cd on c.ConferenceID = cd.ConferenceID
join ConferenceDayReservation cdr on cdr.ConferenceDayID = cd.ConferenceDayID
join ConferenceDayParticipant cdp on cdp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
group by c.ConferenceID

--1i) 20 najpopularniejszych warsztatów


