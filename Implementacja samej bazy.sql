--tabele

use Conferences
drop table Employees
drop table Company
drop table WorkShopParticipant
drop table ConferenceDayParticipant
drop table IndividualClient
drop table Customers
drop table ConferenceParticipant
drop table ConferenceDayReservation
drop table WorkShopReservation
drop table WorkShop
drop table ConferenceDays
drop table Conferences
drop table Reservations
drop table Student

use Conferences
--Conference
create table Conferences(
	ConferenceID int identity(1,1) primary key,
	StartDate date,
	EndDate date,
	City varchar(50),
	Street varchar(50)
) 

alter table Conferences
with check add constraint Conference_dates
check (([StartDate] <= [EndDate]))

--ConferenceDay
create table ConferenceDays(
	ConferenceDayID int identity(1,1) primary key,
	ConferenceID int,
	DayNumber int
)

alter table ConferenceDays
add constraint FK_ConferenceDay_TO_Conference
foreign key (ConferenceID) references Conferences(ConferenceID) on delete cascade

alter table ConferenceDays
with check add constraint ConferenceDay_DayNumber
check (([DayNumber] >= 0))

--Customers

create table Customers(
	CustomerID int identity(1,1) primary key,
	Email char(255),
	PhoneNumber char(50),
	Street char(255),
	PostalCode char(255),
)

use Conferences
alter table Customers
with check add constraint Email_like
check (([Email] like  '%@%')) 

--Company

create table Company(
	CompanyID int identity(1,1) primary key,
	Company char(255) unique ,
	PhoneNumber int unique ,
	CustomerID int
)

alter table Company
add constraint FK_Company_TO_Customer
foreign key (CustomerID) references Customers(CustomerID) on delete cascade

--ConferenceParticipant

use Conferences
create table ConferenceParticipant(
	ConferenceParticipantID int identity(1,1) primary key,
	PersonID int
)

alter table ConferenceParticipant
add constraint FK_ConferenceParticipant_TO_Person
foreign key (PersonID) references Person(PersonID) on delete cascade

--Person
use Conferences
create table Person(
	PersonID int identity(1,1) primary key,
	First_Name char(30),
	Last_Name char(30),
	Phone varchar(50)
)

--Reservations

create table Reservations(
	ReservationID int identity(1,1) primary key,
	RequiredPaymentDate date,
	ReservationDate date,
	CustomerID int,
	ConferenceID int
)

alter table Reservations
add PaymentDate date

alter table Reservations
add constraint FK_Reservations_TO_Conferences
foreign key (ConferenceID) references Conferences(ConferenceID) on delete cascade

alter table Reservations
add constraint FK_Reservations_TO_Customer
foreign key (CustomerID) references Customers(CustomerID)

--ConferenceDayReservation

create table ConferenceDayReservation(
	ConferenceDayReservationID int identity(1,1) primary key,
	NormalTicket decimal(10,2),
	StudentTicket decimal(10,2),
	ConferenceDayID int,
	ReservationID int
)

alter table ConferenceDayReservation
add constraint FK_ConferenceDayReservation_TO_ConferenceDay
foreign key (ConferenceDayID) references ConferenceDays(ConferenceDayID) on delete cascade

alter table ConferenceDayReservation
add constraint FK_ConferenceDayReservation_TO_Reservations
foreign key (ReservationID) references Reservations(ReservationID)

alter table ConferenceDayReservation
with check add constraint ConferenceDayReservation_Price
check (([NormalTicket] >= 0 and [StudentTicket] >= 0))

--WorkShop

use Conferences
create table WorkShop(
	WorkShopID int identity(1,1) primary key,
	WorkShopName char(255),
	SeatsLimit int,
	StartTime datetime,
	EndTime datetime,
	ConferenceDayID int
)

use Conferences
alter table WorkShop
add constraint FK_WorkShop_TO_ConferenceDays
foreign key (ConferenceDayID) references ConferenceDays(ConferenceDayID) on delete cascade

--WorkShopReservation

use Conferences
create table WorkShopReservation(
	WorkShopReservationID int identity(1,1) primary key,
	WebPage char(255),
	NormalTicket decimal(10,2),
	StudentTicket decimal(10,2),
	WorkShopID int
)

use Conferences
alter table WorkShopReservation
add constraint FK_WorkShopReservation_TO_WorkShop
foreign key (WorkShopID) references WorkShop(WorkShopID) on delete cascade

--Employee

use Conferences
create table Employees(
	EmployeeID int identity(1,1) primary key,
	ConferenceParticipantID int,
	CompanyID int
)

use Conferences
alter table Employees
add constraint FK_Employees_TO_Company
foreign key (CompanyID) references Company(CompanyID) on delete cascade

use Conferences
alter table Employees
add constraint FK_Employees_TO_ConferenceParticipantID
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID) on delete no action

--ConferenceDayParticipant

use Conferences
create table ConferenceDayParticipant(
	ConferenceParticipantID int,
	ConferenceDayReservationID int
)

use Conferences
alter table ConferenceDayParticipant
add constraint FK_ConferenceDayParticipant_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID) on delete cascade

use Conferences
alter table ConferenceDayParticipant
add constraint FK_ConferenceDayParticipant_TO_ConferenceDayReservation
foreign key (ConferenceDayReservationID) references ConferenceDayReservation(ConferenceDayReservationID) on delete no action

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
	PersonID int
)

use Conferences
alter table IndividualClient
add constraint FK_IndividualClient_TO_Customer
foreign key (CustomerID) references Customers(CustomerID) on delete cascade

use Conferences
alter table IndividualClient
add constraint FK_IndividualClient_TO_Person
foreign key (PersonID) references Person(PersonID) on delete no action

alter table IndividualClient
drop constraint 

--Student

create table Student(
	StudentCardID int primary key,
	ConferenceParticipantID int not null
)

use Conferences
alter table Student
add constraint FK_Student_TO_ConferenceParticipant
foreign key (ConferenceParticipantID) references ConferenceParticipant(ConferenceParticipantID)

