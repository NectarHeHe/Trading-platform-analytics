select count(*) as customers_count
from customers;
/*
 * запрос из таблицы customers вычисляет при помощи функции count количество строк в таблице
 * то есть, общее количество покупателей
 */


select 
	concat(e.first_name, ' ', e.last_name) as name,
	count(sales_person_id) as operations,
	trunc(sum(quantity * p.price),0) as income
from 
	sales s 
join 
	employees e 
		on s.sales_person_id = e.employee_id
join 
	products p 
		on p.product_id = s.product_id 
group by 
	concat(e.first_name, ' ', e.last_name)
order by 
	income desc nulls last 
limit 10;

/* Запрос обращается к основной таблице продаж
 * к которой присоединяется таблица продавцов и таблица продуктов для получения цены
 * в задании нужно вывести топ 10 работников с самыми высокими продажами
 * для этого мы выводим сконкатенированные имя и фамилию работника, число сделок, сумму его продаж за все время
 * группируемся по сотрудникам чтобы избежать повторений и вывести верную сумму продаж
 * сортируемся по инкаму, чтобы первыми были сотрудники с самой высокой суммой выручки 
 * устанавливаем лимит в 10 сотрудников с самой высокой суммой выручки 
 */

with tab as (select 
	concat(e.first_name, ' ', e.last_name) as name,
	round(avg(quantity * price), 0) as average_income
from 
	sales s 
right join 
	employees e 
	on s.sales_person_id = e.employee_id
left join 
	products p
	on p.product_id = s.product_id 
group by 
	concat(e.first_name, ' ', e.last_name)
order by 
	average_income)
select  
	name, 
	average_income
from 
	tab 
group by 
	name, 
	average_income
having 
	average_income < (select SUM(average_income) / 23 from tab)
order by 
	average_income;


/*
 * Запрос обращается к основной таблице продаж
 * к которой присоединяется таблица продавцов и таблица продуктов
 * в задании нужно вывести продавцов, сумма выручки за одну продажу которых ниже средней
 * для этого мы выводим сконкатенированные имя и фамилию работника, и округленные средние значение дохода за продажу
 * группируем по сотрудником для избежания повторений и получения неверных данных
 * оборачиваем запрос в конструкцию with для получения данных по среднему чеку всех сотрудников
 * добавляем конструкцию having и сравниваем среднюю выручку за продажу продавца со средней выручкой за продажу всех продавцов
 */

select 
	concat(e.first_name, ' ', e.last_name) as name, 
	to_char(sale_date,'Day') as weekday,
	round(sum(quantity * price),0) as income
from 
	sales s 
join 
	employees e 
	on s.sales_person_id = e.employee_id
join 
	products p
	on p.product_id = s.product_id 
group by 
	concat(e.first_name, ' ', e.last_name), 
	s.sale_date 
order by 
	sale_date, 
	concat(e.first_name, ' ', e.last_name);

/* 
 * Запрос обращается к основной таблице продаж
 * к которой присоединяется таблица продавцов
 * по заданию нужен отчет с данными по выручке по каждому продавцу и дню недели
 * для этого мы выводим сконкатенированные имя и фамилию работника, день недели и сумму его продаж в этот день недели
 * группируемся для получения правильных значений без повторов и так же по дате продаж, 
 * чтобы выставить по порядку значения дней недели
 * сортируемся по дню продажи и по сотрудникам
 */

create table customers_age(age_category varchar, count int)

insert into customers_age (age_category, count)
values 
	('16-25', (select count(age) from customers where age between 16 and 25)),
	('26-40', (select count(age) from customers where age between 26 and 40)),
	('40+', (select count(age) from customers where age > 40));

select *
from customers_age;

/* 
 * Запрос получает количество покупателей в разных возрастных группах
 * создал таблицу  customers age с значениями age_category и count
 * добавил в таблицу значения:
 * 1 - категорию возраста
 * 2 - с помощью подзапроса получил число покупателей в разрезе категории возраста
 * Далее выводим запросом полученные значения
 */

select 
	to_char(s.sale_date , 'YYYY-MM') as date,
	count(distinct customer_id) as total_customers,
	trunc(sum(quantity * price),0) as income
from sales s
join 
	products p
	on p.product_id = s.product_id 

group by date
order by date;

/*
 * Мне нужно получить уникальное количество покупателей за каждый месяц и доход который они за этот месяц принесли
 * для того, чтобы мне получить год и месяц, я сконкатенировал вырезанные значения года и месяца полученные при помощи EXTRACT
 * далее я подсчитал количество строк уникальных id покупателей и получил суммарную выручку за месяц при помощи SUM
 * сгруппировал по дате для получения качественных значений без повторов дат 
 */


with tab as (select 
	concat(c.first_name, ' ', c.last_name) as customer,
	s.sale_date,
	concat(e.first_name, ' ', e.last_name) as seller,
	price 
from sales s 
join 
	customers c 
	on c.customer_id = s.customer_id
join 
	products p 
	on p.product_id = s.product_id
join 
	employees e
	on e.employee_id = s.sales_person_id
where price = 0),

tab2 as (select 
			row_number() over(partition by customer order by sale_date) as num_customer, 
			customer, 
			sale_date, 
			seller
		from tab)
select customer, sale_date, seller
from tab2 
where num_customer = 1; 
	
/*
 * Последний отчет мне нужно составить о том, какие покупатели совершили свою первую покупку в период акций
 * мне необходимо вывести имя и фамилию покупателя, дату продажи и данные продавца
 * для этого, в первом запросе я конкатенирую данные покупателя, получаю даты продажи и так же конкатенирую данные продавца
 * получить даты я смог из таблицы sales, данные о продавцах из employees, данные о покупателях из customers
 * в условии сказано, что у акционных товаров указана цена равная 0, фильруем данные по этому условию
 * заворачиваем запрос в конструкцию with, пишем второй запрос для нумерации каждой покупки по покупателю
 * второй запрос так же оборачиваем
 * в третьем запросе выводим необходимые данные и фильтруем их по номеру покупки 1, чтобы получить первую покупку
 * в итоге мы получаем нужные данные, отфильтрованные так, что выводится только первая покупка, которую покупатель совершил
 * в период акции
 */




	


