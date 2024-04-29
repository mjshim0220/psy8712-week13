#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(RMariaDB)
library(keyring)

conn <- dbConnect(MariaDB(),
                  user="shim0220",
                  password=key_get("latis-mysql","shim0220"),
                  host="mysql-prod5.oit.umn.edu", 
                  port=3306,
                  ssl.ca='mysql_hotel_umn_20220728_interm.cer')

#Data Import and Cleaning
dbExecute(conn, "USE cla_tntlab;")

##Q1.
manager<- dbGetQuery(conn,
"SELECT COUNT(*) AS total_manager
FROM datascience_employees AS e
INNER JOIN datascience_testscores AS t 
ON e.employee_id = t.employee_id
AND t.test_score IS NOT NULL;")
                     
manager

##Q2. 
unq_manager<-dbGetQuery(conn,
"SELECT COUNT(DISTINCT e.employee_id) AS unique_manager
FROM datascience_employees AS e
INNER JOIN datascience_testscores AS t 
ON e.employee_id = t.employee_id
AND t.test_score IS NOT NULL;")
unq_manager

##Q3. 
city_n_manager<-dbGetQuery(conn,
"SELECT e.city, COUNT(*) AS total_manager
FROM datascience_employees AS e
INNER JOIN datascience_testscores AS t 
ON e.employee_id = t.employee_id
WHERE t.test_score IS NOT NULL
AND e.manager_hire = 'N'
GROUP BY e.city;")

city_n_manager

##Q4.
performance<-dbGetQuery(conn,
"SELECT performance_group,
AVG(yrs_employed) AS mean,
STDDEV(yrs_employed) AS sd
FROM datascience_employees AS e
INNER JOIN datascience_testscores AS t 
ON e.employee_id = t.employee_id
WHERE t.test_score IS NOT NULL
GROUP BY performance_group;")

performance

##Q5.
s_manager<-dbGetQuery(conn,
"SELECT o.type, e.employee_id, t.test_score
FROM datascience_employees AS e
INNER JOIN datascience_testscores AS t 
ON e.employee_id = t.employee_id
FULL JOIN datascience_offices AS o
ON e.city = o.office
WHERE t.test_score IS NOT NULL
ORDER BY o.type ASC, t.test_score DESC;")
