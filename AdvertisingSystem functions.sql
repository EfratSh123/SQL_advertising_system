--הצגת לקוחות וותיקים- פרסמו לפחות 2 פעמים
--מציג שם לקוח וכמות פעמים פרסם
--***
select cl_firstName+' '+cl_lastName as clientName,
count(a_code) as amount
from Clients
inner join Orders
on cl_id = o_cl_id
inner join Advertisements
on o_a_code = a_code
group by cl_firstName+' '+cl_lastName
having count(a_code)>2

--הצגת כמות עבודות שעשתה גרפיקאית מסויימת
--***

create procedure AmountWorking @g_id varchar(9), @access int
as 
begin 
if (select ac_code from Access where ac_code=@access)=0
	begin
		select g_firstName+' '+g_lastName as graficName, count(a_code) as count1
		from Advertisements
		inner join GraphicArtist on a_g_id = g_id
		where a_g_id = @g_id 
		group by g_firstName+' '+g_lastName
		having count(a_code)>0 
	end
else
	print 'there is no Permission'
end
exec AmountWorking '327812855',1
select * from GraphicArtist
select * from Advertisements order by a_g_id

--הצגת פרסומות להיום
--***
go
alter view AdvertisementsForToday as
select a_code as advertisementsCode,
a_size as size,
a_g_id as graphicArtistId
from Advertisements inner join Orders
on a_code = o_a_code
inner join DatesAdvertising
on o_code = d_o_code
where d_date =  getDate()
group by a_code ,a_size, a_g_id

select * from AdvertisementsForToday

--הצגת גרפיקאית שהפרסומות שלה פורסמו הכי הרבה פעמים
--***
select top 1 g_id, g_firstName+' '+g_lastName as g_name,
count(d_code) as total_ad
from GraphicArtist 
inner join Advertisements on g_id = a_g_id
inner join Orders on a_code = o_a_code
inner join DatesAdvertising on o_code = d_o_code
group by g_id,  g_firstName+' '+g_lastName
order by total_ad desc

--עדכון שנות וותק של גרפיקאית מסויימת
--***
go
create procedure UpdateSeniority @g_id int, @access int
as 
if (select ac_code from Access where ac_code=@access)=0
begin
	update GraphicArtist
	set g_seniority = 
	(select g_seniority
	from GraphicArtist
	where g_id = @g_id) +1
	where g_id = @g_id
end
else
	print 'there is no Permission'
exec UpdateSeniority 327866679,1
select * from GraphicArtist


--הצגת פרסומות שצריכות להיות מוכנות בשבוע הקרוב
--***
go
create view ShowWorkThisWeek as
select a_code, a_g_id, a_size, a_text from Advertisements
inner join Orders on a_code = o_a_code
inner join DatesAdvertising on o_code = d_o_code
where cast(d_date as date) = DATEADD(YEAR, 1, GETDATE())
group by a_code, a_g_id, a_size, a_text 

select * from ShowWorkThisWeek

--הצגת עבודות לגרפיקאית מסויימת שעליה לבצע בשבוע הקרוב 
--***
create function WorkGraficsThisWeek (@g_id int)
returns table
as
return (select * from ShowWorkThisWeek where a_g_id = @g_id)

select * from [dbo].[WorkGraficsThisWeek](214824328)
select * from GraphicArtist
--חיפוש פרסומות של לקוח מסויים- בשביל לפרסם אותה שוב
--מחזיר טבלה ובה פרטי פרסומות של הלקוח הזה

--***
go
create function FindAdvertisement (@cl_id int)
returns table
as
return (select a_code,a_g_id,a_size,a_text
from Advertisements 
left join orders
on a_code = o_a_code
where o_cl_id = @cl_id
group by a_code,a_g_id,a_size,a_text)

select * from [dbo].[FindAdvertisement](327706123)

--הוספת הזמנה שתקושר לפרסומת מסויימת
--***
go
create procedure AddOrderWithAdvertisementCode(@cl_id varchar(9) ,@a_code int, @dateOrder date, @access int)
as
begin
if (select ac_code from Access where ac_code=@access)=0
begin
	insert into [dbo].Orders values (@cl_id, @dateOrder, @a_code,280)
end
else
	print 'there is no Permission'
exec [dbo].AddOrderWithAdvertisementCode '022852107',6554, '07-03-2024',0
select * from orders

--עדכון מחיר הזמנה בהוספת תאריך פרסום
--***
create trigger UpdatePrice
on [dbo].[DatesAdvertising]
for insert
as begin
	update Orders set o_price= o_price +25 * a_size
    from Orders inner join Advertisements on a_code = o_a_code
    inner join inserted on o_code = d_o_code
end
select * from Orders
insert into DatesAdvertising values('08-03-2024',1200)

--בהוספת הזמנה- לקבוע במחיר עלות עיצוב פרסומת-280
--***
create trigger DefaultPrice
on [dbo].[Orders]
for insert
as begin
	declare @a int
    select @a = (select o_price from Orders where o_code in (select o_code from inserted))
	if @a is null
		begin
        update Orders set o_price = 280 where o_code in (select o_code from inserted)
        end
end
insert into Orders values ('022852107','07-07-2024',6554,null)
select * from Orders
select * from DatesAdvertising

--הצגת הזמנות שלא שולמו
--***
select o_code,o_dateOrder ,o_a_code, o_price,
cl_id, cl_firstName+' '+cl_lastName
from Orders
inner join Payments on o_code = p_o_code
inner join clients on o_cl_id = cl_id
where p_status = 'Paid'
group by  o_code,o_dateOrder ,o_a_code,
o_price, cl_id, cl_firstName+' '+cl_lastName

--להציג לכל לקוח את מספר הפרסומות שעדין לא פורסמו 
--שהם של הלקוחות שקיימים למעלה משנתיים
--***
select cl_firstName+' '+cl_lastName as clientName,
count(d_code) as amount
from Clients
inner join Orders
on cl_id = o_cl_id
inner join DatesAdvertising
on o_code = d_o_code
--פרסומות שלא פורסמו
where d_date < GETDATE()
--ולקוח קיים למעלה משנתיים
and cl_id in(
	select distinct cl_id from Clients
	inner join Orders on cl_id = o_cl_id
	inner join DatesAdvertising on o_code = d_o_code
	where (select MIN(d_date)
	from DatesAdvertising) < dateadd(year, -2 ,GETDATE())
)
group by cl_firstName+' '+cl_lastName
having  count(d_code)>0 

--שאילתה המציגה את הלקוח הכי משתלם
--ממוצע הפעימות של ההזמנות שלו הוא הגבוהה ביותר
--***

select top 1 cl_id, 
count(o_code) as o_count, 
count(d_code) as d_count, 
(count(d_code))*1.0/(count(o_code)) as avg1
from Clients
left join Orders on cl_id = o_cl_id
left join DatesAdvertising on o_code = d_o_code
group by cl_id 
having count(o_code)<>0
order by  avg1 desc

insert into Orders values ('028004133','07-10-2024',6555,null)
insert into Advertisements values ('327866679',20,'')
select o_code from Orders order by o_cl_id
select * from DatesAdvertising order by d_o_code
select * from Advertisements

--שיבוץ עבודה לגרפיקאית
--לפי הזמן הפנוי שלה וימי העבודה שהיא עובדת
create trigger PlacementGraphic
on [dbo].[DatesAdvertising]
for insert
as begin
	--לבדוק האם זה הוספה של תאריך פרסום ראשון- שאז צריך לשבץ
	declare @d_o_code int, @count int, @d_date date
	select @d_o_code = d_o_code from inserted	
	select @count = count(d_code) from DatesAdvertising where d_o_code = @d_o_code
	if(@count = 1)
	begin
		set @d_date = check_order((select d_date from inserted))
		update Advertisements set a_g_id = (select g_id from [dbo].check_order(@d_date))
		where a_code = (select o_a_code from Orders inner join DatesAdvertising on o_code = d_o_code
		where o_code = (select d_o_code from inserted))
	end
end

go
create function check_order(@date date)
returns @result table(count_o_code int, calc_result int, g_id int, minimum int)
as
begin
	declare @weeks int
	set @weeks=datediff(week,getdate(),@date)
	insert into @result
	select top 1 count(o_code),[dbo].count_days(g_id)*@weeks,g_id,[dbo].count_days(g_id)*@weeks/count(o_code) as minimum
	from DatesAdvertising inner join Orders on d_o_code=o_code inner join Advertisements
	on o_a_code=a_code inner join GraphicArtist on a_g_id=g_id 
	where d_date between GETDATE() and '01-01-2024' group by g_id order by minimum
	return
end

create function count_days(@id varchar(9))
returns int
as
begin
	declare @sum int=0,@days varchar(5) ,@days_int int,@i int=0
	select @days= g_daysWorking from GraphicArtist where g_id=@id
	while @i<5
	begin
	set @sum=@sum+cast((substring(@days, @i,  1)) as int)
	set @i=@i+1
	end
	return @sum
end
select [dbo].count_days('327866679')