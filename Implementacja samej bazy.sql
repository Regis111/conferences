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


--Company

use Siwik
create table Company(
	CompanyID int primary key,
	Company char(255) unique ,
	PhoneNumber int unique ,
	CustomerID int
)

use Siwik
alter table Company
add constraint FK_Company_TO_Customer
foreign key (CustomerID) references Customer(CustomerID)

--ConferenceParticipant

use Siwik
create table ConferenceParticipant(
	ConferenceParticipantID int primary key,
	First_Name char(30),
	Last_Name char(30),
	PhoneNumber int unique,
	IsStudent bit,
	ConferenceDayReservationID int unique 
)

use Siwik
alter table ConferenceParticipant
add constraint FK_TO_ConferenceDayReservation
foreign key (ConferenceDayReservationID) references ConferenceDayReservation(ConferenceDayReservationID)

--WorkShopReservation

use Siwik
create table WorkShopReservation(
	WorkShopReservationID int primary key,
	WebPage char(255),
	Discount int,
	WorkShopID int unique
)

use Siwik
alter table WorkShopReservation
add constraint CK_DiscountValue 
check ([Discount] >=0 and [Discount] <= 99)

use Siwik
alter table WorkShopReservation
add constraint FK_WorkShopReservation_TO_WorkShop
foreign key (WorkShopID) references WorkShop(WorkShopID)

--WorkShop

use Siwik
create table WorkShop(
	WorkShopID int primary key,
	WorkShopName char(255),
	ReservedSeats int,
	SeatsLimit int,
	StartTime time,
	EndTime time,
	ConferenceDayID int
)

use Siwik
alter table WorkShop
add constraint FK_WorkShop_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDay(ConferenceDayID)

--Employee

use Siwik
create table Employee(
	EmployeeID int primary key,
	ConferenceParticipantID int,
	CompanyID int
)

use Siwik
alter table Employee
add constraint FK_Employee_TO_Company
foreign key (CompanyID) references Company(CompanyID)

use Siwik
alter table Employee
add constraint FK_Employee_TO_ConferenceParticipantID
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID)

--ConferenceDayParticipant

use Siwik
create table ConferenceDayParticipant(
	ConferenceParticipantID int,
	ConferenceDayID int
)

use Siwik
alter table ConferenceDayParticipant
add constraint FK_ConferenceDayParticipant_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID)

use Siwik
alter table ConferenceDayParticipant
add constraint FK_ConferenceDayParticipant_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDay(ConferenceDayID)

--WorkShopParticipant

use Siwik
create table WorkShopParticipant(
	ConferenceParticipantID int,
	WorkShopReservationID int
)

use Siwik
alter table WorkShopParticipant
add constraint FK_WorkShopParticipant_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID)

use Siwik
alter table WorkShopParticipant
add constraint FK_WorkShopParticipant_TO_WorkShopReservation
foreign key (WorkShopReservationID) references WorkShopReservation(WorkShopReservationID)

--IndividualClient

use Siwik
create table IndividualClient(
	CustomerID int,
	ConferenceParticipantID int
)

use Siwik
alter table IndividualClient
add constraint FK_IndividualClient_TO_Customer
foreign key (CustomerID) references Customer(CustomerID)

use Siwik
alter table IndividualClient
add constraint FK_IndividualClient_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID)




