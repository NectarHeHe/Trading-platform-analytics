select count(*) as customers_count
from customers;
/*
 * запрос из таблицы customers вычисляет при помощи функции count количество строк в таблице
 * то есть, общее количество покупателей
 */


select 
concat(e.first_name, ' ', e.last_name) as employees,
count(sales_person_id) as operations,
sum(quantity) as income
from sales s 
right join employees e 
on s.sales_person_id = e.employee_id
group by employees
order by income desc nulls last 
limit 10;

/* Запрос обращается к основной таблице продаж
 * к которой присоединяется таблица продавцов
 * в задании нужно вывести топ 10 работников с самыми высокими продажами
 * для этого мы выводим сконкатенированные имя и фамилию работника, число сделок, сумму его продаж за все время
 * группируемся по сотрудникам чтобы избежать повторений и вывести верную сумму продаж
 * так же я обработал NULL значение, хотя в этом не было необходимости, тк в топ 10 бы этот работник не попал
 * сортируемся по инкаму, чтобы первыми были сотрудники с самой высокой суммой выручки 
 * устанавливаем лимит в 10 сотрудников с самой высокой суммой выручки 
 */

with tab as (select 
	concat(e.first_name, ' ', e.last_name) as employees,
	coalesce (round(avg(quantity), 0),0) as average_income
from 
	sales s 
right join 
	employees e 
	on s.sales_person_id = e.employee_id
group by 
	employees
order by 
	average_income)
select  
	employees, 
	average_income
from 
	tab 
group by 
	employees, 
	average_income
having 
	average_income < (select SUM(average_income) / 23 from tab)
order by 
	average_income;


/*
 * Запрос обращается к основной таблице продаж
 * к которой присоединяется таблица продавцов
 * в задании нужно вывести продавцов, сумма выручки за одну продажу которых ниже средней
 * для этого мы выводим сконкатенированные имя и фамилию работника, и округленные средние значение дохода за продажу
 * так же обрабатываю NULL, чтобы человек который не продавал и ничего не заработал, так же был в конечной таблице
 * Right join так же нужен был для того, чтобы получить продавца не совершившего ни одной сделки
 * группируем по сотрудником для избежания повторений и получения неверных данных
 * оборачиваем запрос в конструкцию with для получения данных по среднему чеку всех сотрудников
 * добавляем конструкцию having и сравниваем среднюю выручку за продажу продавца со средней выручкой за продажу всех продавцов
 */

select 
	concat(e.first_name, ' ', e.last_name) as employees, 
	coalesce (to_char(sale_date,'Day'),'no data') as weekday,
	coalesce (sum(quantity),0) as income
from 
	sales s 
right join 
	employees e 
	on s.sales_person_id = e.employee_id
group by 
	employees, 
	weekday,
	sale_date 
order by 
	sale_date, 
	employees;

/* 
 * Запрос обращается к основной таблице продаж
 * к которой присоединяется таблица продавцов
 * по заданию нужен отчет с данными по выручке по каждому продавцу и дню недели
 * для этого мы выводим сконкатенированные имя и фамилию работника, день недели и сумму его продаж в этот день недели
 * не забываем обработать значение работника, который сделал 0 продаж
 * группируемся для получения правильных значений без повторов и так же по дате продаж, 
 * чтобы выставить по порядку значения дней недели
 * сортируемся по дню продажи и по сотрудникам
 */


	


