use Siwik
--conference
create table Conference(
	ConferenceID int primary key,
	StartDate date,
	EndDate date,
	Addres varchar(50)
)

--conferenceDay
create table ConferenceDay(
	ConferenceDayID int primary key,
	ConferenceID int,
	DayNumber int
)

alter table ConferenceDay
add constraint FK_ConferenceDay_TO_Conference
foreign key (ConferenceID) references Conference(ConferenceID)

--ConferenceDayReservation

create table ConferenceDayReservation(
	ConferenceDayReservationID int primary key,
	Price int,
	SeatsBooked int,
	Discount decimal(10,2),
	ConferenceDayID int
)

alter table ConferenceDayReservation
add constraint FK_ConferenceDayReservation_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDay(ConferenceDayID)

--Customer

create table Customer(
	CustomerID int primary key,
	Email char(255),
	Street char(255),
	PostalCode char(255),
	ConferenceDayReservationID int
)

alter table Customer
add constraint FK_Customer_TO_ConferenceDayReservation
foreign key (ConferenceDayReservationID) references ConferenceDayReservation(ConferenceDayReservationID)

