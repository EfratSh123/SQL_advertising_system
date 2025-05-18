create database AdvertisingSystem
create table Access(
	ac_code int primary key identity(0,1) not null,
	ac_name varchar(15) not null
)
insert into Access values('grafic'),('principal')

create table Clients(
	cl_id varchar(9) primary key not null,
	cl_firstName varchar(10) not null,
	cl_lastName varchar(20) not null,
	cl_tel varchar(10) not null,
	cl_mail varchar(30) not null,
)
alter table [dbo].[Clients] add constraint cl_tel  check ([cl_tel] like '05[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
alter table [dbo].[Clients] add constraint cl_id  check ([cl_id] like ('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))

insert into Clients values
				('327706123','Efrat','Shmueli','0534115914','efrat4115914@gmail.com'),
				('022852107','Sara','Ravitz','0548541132','Sara1132@gmail.com'),
				('327772190','Rut','Weisfish','0504168523','ruti411@gmail.com'),
				('028004133','Lea','Bayfus','0548461179','lea0548461179@gmail.com')
create table GraphicArtist(
	g_id varchar(9) primary key not null,
	g_firstName varchar(10) not null, 
	g_lastName varchar(20) not null,
	g_tel varchar(10) not null,
	g_mail varchar(30) not null,
	--וותק
	g_seniority int,
	g_daysWorking varchar(5),
	g_access int foreign key references Access(ac_code) not null
)
alter table [dbo].[GraphicArtist] add constraint g_id  check ([g_id] like ('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
alter table [dbo].[GraphicArtist] add constraint g_tel check ([g_tel] like '05[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
alter table [dbo].[GraphicArtist] add constraint g_daysWorking check ([g_daysWorking] like '[0-1][0-1][0-1][0-1][0-1]')

insert into GraphicArtist values
				('327812855','Ayala','Shock','0532145887','Ayala887@gmail.com',5,'11111',0),
				('327866679','Efrat','Shock','0534115643','0775462251@gmail.com',2,'10111',1),
				('208096081','Esti','Tzvaig','0552468895','Esti132@gmail.com',3,'01110',1),
				('214824328','Chani','Mualem','0504176999','Mualem2020@gmail.com',10,'11111',1)
create table Advertisements(
	a_code int identity(6551,1) primary key not null,
	a_g_id varchar(9) foreign key references GraphicArtist(g_id) not null,
	--גודל לפחות 10 סמ"ר -5*2 ס"מ
	a_size float not null,
	--טקסט נוסף לפני הפרסומת
	a_text varchar(50)
)
alter table [dbo].[Advertisements] add constraint a_size check ([a_size] between 10 and 40)

insert into Advertisements values
				('214824328',10,''),
				('327812855',30,''),
				('208096081',20,''),
				('214824328',25,'')
create table Orders(
	o_code int identity(1200,1) primary key not null,
	o_cl_id varchar(9) foreign key references Clients(cl_id) not null,
	o_dateOrder date not null,
	o_a_code int foreign key references Advertisements(a_code) not null,
	--מחיר- עלות עיצוב פרסומת + עלות פרסום(גודל*25) * מספר פעימות
	o_price float 
)
alter table [dbo].[Orders] add constraint o_price1 check ([o_price] >279)

insert into Orders values
				('327706123','06-20-2024',6551,500),
				('022852107','06-18-2024',6552,1000),
				('327706123','07-23-2024',6553,750),
				('327706123','07-21-2024',6554,875)
create table Payments(
	p_code int identity(754465,1) primary key not null,
	p_o_code int foreign key references Orders(o_code) not null,
	p_numOfPayments int not null,
	p_paymentMethods varchar(20) not null,
	p_attachment varchar(20),
	p_creditNum int,
	p_creditVaild date,
	p_creditCVV int,
	p_cardHolderId varchar(9),
	p_status varchar(6)
)
alter table [dbo].[Payments] add constraint p_numOfPayments check ([p_numOfPayments] between 1 and 5)
alter table [dbo].[Payments] add constraint p_paymentMethods check ([p_paymentMethods] in('Bank Transfer','credit card'))
alter table [dbo].[Payments] add constraint p_creditNum check ([p_creditNum] like('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
alter table [dbo].[Payments] add constraint p_creditVaild check ([p_creditVaild] like('[0-9][0-9][/][0-9][0-9]'))
alter table [dbo].[Payments] add constraint p_creditCVV check ([p_creditCVV] like('[0-9][0-9][0-9]'))
alter table [dbo].[Payments] add constraint p_status check ([p_status] in('Paid','Unpaid'))

--הכנסת נתוניםםםםםםםםםםםם


create table DatesAdvertising(
	d_code int identity(101,1) primary key not null,
	d_date date not null,
	d_o_code int foreign key references Orders(o_code) not null
)
insert into DatesAdvertising values
			('06-25-2024',1200),
			('07-02-2024',1201),
			('06-25-2024',1202),
			('07-02-2024',1200)
