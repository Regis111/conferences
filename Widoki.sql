--WIDOKI

--1a)

create view WorkShopInformation as
select cd.ConferenceID,cd.DayNumber,ws.WorkShopName,ws.SeatsLimit as max_number_of_people,ws.ReservedSeats as number_of_people_reserved
from ConferenceDays cd
join WorkShop ws on cd.ConferenceDayID = ws.ConferenceDayID

--1b)

create view [SortedCustomers] as
select top 20 c.CustomerID, count(r.ReservationID) as number_of_reservations
from Customers c
join Reservations r on r.CustomerID = c.CustomerID
group by c.CustomerID
order by number_of_reservations desc 

--1c)

create view [UnPaidReservationsOfIndividualClients] as
select c.CustomerID,cp.First_Name,cp.Last_Name,r.ReservationID from Reservations r
join Customers c on r.CustomerID = c.CustomerID
join IndividualClient i on i.CustomerID = c.CustomerID
join ConferenceParticipant cp on cp.ConferenceParticipantID = i.ConferenceParticipantID
where r.PaymentDate is null

--1d)

create view [UnPaidReservationsOfClients] as
select cu.CustomerID,cp.First_Name,cp.Last_Name,r.ReservationID from Reservations r
join Customers cu on r.CustomerID = cu.CustomerID
join Company co on co.CustomerID = cu.CustomerID
join Employees e on e.CompanyID = co.CompanyID
join ConferenceParticipant cp on cp.ConferenceParticipantID = e.ConferenceParticipantID
where r.PaymentDate is null

1e)


