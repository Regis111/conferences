--1a)

create view WorkShopInformation as
select cd.ConferenceID,cd.DayNumber,ws.WorkShopName,ws.SeatsLimit as max_number_of_people,ws.ReservedSeats as number_of_people_reserved
from ConferenceDays cd
join WorkShop ws on cd.ConferenceDayID = ws.ConferenceDayID

--1b)

--1c)

create view [SortedCustomers] as
select top 20 c.CustomerID, count(r.ReservationID) as number_of_reservations
from Customers c
join Reservations r on r.CustomerID = c.CustomerID
group by c.CustomerID
order by number_of_reservations desc 

--1d)




