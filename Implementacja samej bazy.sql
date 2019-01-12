
--tabele

use Conferences
drop table Employee
drop table Company
drop table WorkShopParticipant
drop table ConferenceDayParticipant
drop table IndividualClient
drop table Customer
drop table ConferenceParticipant
drop table ConferenceDayReservation
drop table WorkShopReservation
drop table WorkShop
drop table ConferenceDay
drop table Conference


use Conferences
--Conference
create table Conference(
	ConferenceID int identity(1,1) primary key,
	StartDate date,
	EndDate date,
	Addres varchar(50)
)

alter table Conference
with check add constraint Conference_dates
check (([StartDate] <= [EndDate]))

--ConferenceDay
create table ConferenceDay(
	ConferenceDayID int identity(1,1) primary key,
	ConferenceID int,
	DayNumber int
)

alter table ConferenceDay
add constraint FK_ConferenceDay_TO_Conference
foreign key (ConferenceID) references Conference(ConferenceID) on delete cascade

alter table ConferenceDay
with check add constraint ConferenceDay_DayNumber
check (([DayNumber] >= 0))

--ConferenceDayReservation

create table ConferenceDayReservation(
	ConferenceDayReservationID int identity(1,1) primary key,
	Price int,
	SeatsBooked int,
	Discount decimal(10,2),
	ConferenceDayID int
)

alter table ConferenceDayReservation
add constraint FK_ConferenceDayReservation_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDay(ConferenceDayID) on delete cascade

alter table ConferenceDayReservation
with check add constraint ConferenceDayReservation_Price
check (([Price] >= 0))

--Customer

create table Customer(
	CustomerID int identity(1,1) primary key,
	Email char(255),
	Street char(255),
	PostalCode char(255),
	ConferenceDayReservationID int
)

alter table Customer
add constraint FK_Customer_TO_ConferenceDayReservation
foreign key (ConferenceDayReservationID) references ConferenceDayReservation(ConferenceDayReservationID) on delete cascade

use Conferences
alter table [dbo].[Customer]
with check add constraint Email_like
check (([Email] like  '%@%')) 

--Company

use Conferences
create table Company(
	CompanyID int identity(1,1) primary key,
	Company char(255) unique ,
	PhoneNumber int unique ,
	CustomerID int
)

use Conferences
alter table Company
add constraint FK_Company_TO_Customer
foreign key (CustomerID) references Customer(CustomerID) on delete cascade

--ConferenceParticipant

use Conferences
create table ConferenceParticipant(
	ConferenceParticipantID int identity(1,1) primary key,
	First_Name char(30),
	Last_Name char(30),
	PhoneNumber int unique,
	IsStudent bit,
	ConferenceDayReservationID int unique 
)

use Conferences
alter table ConferenceParticipant
add constraint FK_TO_ConferenceDayReservation
foreign key (ConferenceDayReservationID) references ConferenceDayReservation(ConferenceDayReservationID) on delete cascade

--WorkShop

use Conferences
create table WorkShop(
	WorkShopID int identity(1,1) primary key,
	WorkShopName char(255),
	ReservedSeats int,
	SeatsLimit int,
	StartTime time,
	EndTime time,
	ConferenceDayID int
)

use Conferences
alter table WorkShop
add constraint FK_WorkShop_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDay(ConferenceDayID) on delete cascade

--WorkShopReservation

use Conferences
create table WorkShopReservation(
	WorkShopReservationID int identity(1,1) primary key,
	WebPage char(255),
	Discount int,
	WorkShopID int unique
)

use Conferences
alter table WorkShopReservation
add constraint CK_DiscountValue 
check ([Discount] >=0 and [Discount] <= 1)

use Conferences
alter table WorkShopReservation
add constraint FK_WorkShopReservation_TO_WorkShop
foreign key (WorkShopID) references WorkShop(WorkShopID) on delete cascade

--Employee

use Conferences
create table Employee(
	EmployeeID int identity(1,1) primary key,
	ConferenceParticipantID int,
	CompanyID int
)

use Conferences
alter table Employee
add constraint FK_Employee_TO_Company
foreign key (CompanyID) references Company(CompanyID) on delete cascade

use Conferences
alter table Employee
add constraint FK_Employee_TO_ConferenceParticipantID
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID) on delete no action

--ConferenceDayParticipant

use Conferences
create table ConferenceDayParticipant(
	ConferenceParticipantID int,
	ConferenceDayID int
)

use Conferences
alter table ConferenceDayParticipant
add constraint FK_ConferenceDayParticipant_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID) on delete cascade

use Conferences
alter table ConferenceDayParticipant
add constraint FK_ConferenceDayParticipant_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDay(ConferenceDayID) on delete no action

--WorkShopParticipant

use Conferences
create table WorkShopParticipant(
	ConferenceParticipantID int,
	WorkShopReservationID int
)

use Conferences
alter table WorkShopParticipant
add constraint FK_WorkShopParticipant_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID) on delete cascade

use Conferences
alter table WorkShopParticipant
add constraint FK_WorkShopParticipant_TO_WorkShopReservation
foreign key (WorkShopReservationID) references WorkShopReservation(WorkShopReservationID) on delete no action

--IndividualClient

use Conferences
create table IndividualClient(
	CustomerID int,
	ConferenceParticipantID int
)

use Conferences
alter table IndividualClient
add constraint FK_IndividualClient_TO_Customer
foreign key (CustomerID) references Customer(CustomerID) on delete cascade

use Conferences
alter table IndividualClient
add constraint FK_IndividualClient_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID) on delete no action