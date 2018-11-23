-- Запрос 1:
-- Подсчитать общее количество писем
select count(*) from emails;

-- Запрос 2:
-- Подсчитать общее количест получателей
select count(distinct personid) from emailreceivers;

-- Запрос 3:
-- Подсчитать количество отправленных писем за 2012
select count(*) from emails
where MetadataDateSent >= '2012-01-01' and
    MetadataDateSent < '2013-01-01';

-- Запрос 4:
-- Вывести все псевдонимы получаталей, отсортировать по количеству псевдонимов
select Name, array_agg(distinct Alias) as aliases_array from aliases
join persons on aliases.personid = persons.id
group by Name order by array_length(array_agg(Alias), 1) offset 10 limit 10;

-- Запрос 5:
-- Вывести список писем в следующем формате:
-- Отправитель письма, получатель письма, тема письма,
-- и отсортированы по теме письма.
select MetadataFrom as from,
       MetadataTo as to,
       MetadataSubject as subject
from emails order by subject limit 10;

-- Запрос 6:
-- Вывести среднюю длинну сообщения
select avg(length(ExtractedBodyText)) as text from emails;

-- Запрос 7:
-- Вывести количество писем, в которых содержится подстрока UNCLASSIFIED
select count(ExtractedBodyText) as text
from emails where ExtractedBodyText like '%UNCLASSIFIED%' limit 10;

-- Запрос 8:
-- Подсчитать количество писем, которое было полученно каждым получателем и
-- отсортировать по убыванию.
select PersonId, count(Emailid) from emailreceivers
group by PersonId order by count(Emailid) desc limit 10;

-- Запрос 9:
-- Подсчитать количество писем, которое было полученно каждым получателем и
-- отсортировать по убыванию. Необходимо вывести в следующем формате:
-- Имя персоны, количество писем
select Name, count(Emailid) from (
    select Name, Emailid from emailreceivers
    join persons on emailreceivers.personid = persons.id) as tmp_table
group by Name order by count(Emailid) desc limit 10;

-- Запрос 10:
-- Подсчитать среднюю длину письма у кажого получателя и отсортировать
-- по убыванию
select Name, avg(len) from (
    select Name, length(ExtractedBodyText) as len from emails
    join persons on emails.SenderPersonId = persons.id
    where ExtractedBodyText is not null) as tmp_table
group by Name order by avg(len) desc limit 10;

-- Создание представления на основе запроса 1
create or replace view email_counts as
select count(*) from emails;

-- Создание представления на основе запроса 10
create or replace view avg_mail_len as
select Name, avg(len) from (
    select Name, length(ExtractedBodyText) as len from emails
    join persons on emails.SenderPersonId = persons.id
    where ExtractedBodyText is not null) as tmp_table
group by Name order by avg(len) desc limit 10;
