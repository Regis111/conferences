--WIDOKI

--1a) wszystkie warsztaty z informacj� o dniu, konferencji i liczbie os�b

create view [WorkShopInformation] as
select cd.ConferenceID,cd.DayNumber,ws.WorkShopName,ws.SeatsLimit as max_number_of_people,ws.ReservedSeats as number_of_people_reserved
from ConferenceDays cd
join WorkShop ws on cd.ConferenceDayID = ws.ConferenceDayID

--1b) 20 najbardziej aktywnych klient�w

create view [SortedCustomers] as
select top 20 c.CustomerID, count(r.ReservationID) as number_of_reservations
from Customers c
join Reservations r on r.CustomerID = c.CustomerID
group by c.CustomerID
order by number_of_reservations desc 

--1c) nieop�acone rezerwacje indywidualanych klient�w

create view [UnPaidReservationsOfIndividualClients] as
select c.CustomerID,cp.First_Name,cp.Last_Name,r.ReservationID from Reservations r
join Customers c on r.CustomerID = c.CustomerID
join IndividualClient i on i.CustomerID = c.CustomerID
join ConferenceParticipant cp on cp.ConferenceParticipantID = i.ConferenceParticipantID
where r.PaymentDate is null

--1d) nieop�acone rezerwacje firm

create view [UnPaidReservationsOfClients] as
select cu.CustomerID,cp.First_Name,cp.Last_Name,r.ReservationID from Reservations r
join Customers cu on r.CustomerID = cu.CustomerID
join Company co on co.CustomerID = cu.CustomerID
join Employees e on e.CompanyID = co.CompanyID
join ConferenceParticipant cp on cp.ConferenceParticipantID = e.ConferenceParticipantID
where r.PaymentDate is null

--1e) warsztaty na kt�re zosta�y wolne miejsca

create view [AvailableWorkShops] as
select cd.ConferenceID,cd.ConferenceDayID,cd.DayNumber,w.WorkShopID,w.WorkShopName from ConferenceDays cd
join WorkShop w on cd.ConferenceDayID = w.ConferenceDayID
where (w.SeatsLimit - w.ReservedSeats) > 0

--1f) rezerwacje kt�re maj� by� op�acone do jutra

--1g) ilo�� rezerwacji na konferencje

--1h) 

