#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(keyring)
library(RMariaDB)
library(tidyverse)

conn <- dbConnect(MariaDB(),
                  user="shim0220",
                  password=key_get("latis-mysql","shim0220"),
                  host="mysql-prod5.oit.umn.edu", 
                  port=3306,
                  ssl.ca='mysql_hotel_umn_20220728_interm.cer')

#Data Import and Cleaning
db<-dbGetQuery(conn, "SHOW DATABASES;")
dbExecute(conn, "USE cla_tntlab;")

##Download the datasets from UMN SQL server
employees_tbl<-dbGetQuery(conn, "SELECT * FROM datascience_employees;") %>% 
  as_tibble()
testscores_tbl<-dbGetQuery(conn, "SELECT * FROM datascience_testscores;") %>% 
  as_tibble()
offices_tbl<-dbGetQuery(conn, "SELECT * FROM datascience_offices;") %>% 
  as_tibble()

##Save the datasets into csv
write_csv(employees_tbl, "../data/employees.csv")
write_csv(testscores_tbl, "../data/testscores.csv")
write_csv(offices_tbl, "../data/offices.csv")

##Week13 df
week13_tbl<-employees_tbl %>% 
  inner_join(testscores_tbl, by="employee_id") %>%
  full_join(offices_tbl, by=c("city" = "office"))

write_csv(week13_tbl, "../out/week13.csv")

#Analysis
##1.Total number of managers
manager<-week13_tbl %>% 
  summarize(n())
manager

##2.Total number of unique managers
unq_manager<-week13_tbl %>% 
  select(employee_id) %>% 
  unique() %>% 
  summarize(n())
unq_manager

##3.Summary of the number of managers split by location (not including those who starting from manager level)
city_n_manager<-week13_tbl %>% 
  filter(manager_hire=="N") %>% 
  group_by(city) %>% 
  summarize(n())
city_n_manager

##4.Mean and sd of number of years of employment split by performance level
performance<-week13_tbl %>% 
  group_by(performance_group) %>% 
  summarize(mean=mean(yrs_employed),
            sd=sd(yrs_employed))
performance

##5.Manager's location, ID number, and test score in alphabetical order by location type and then descending order of test score
s_manager<-week13_tbl %>% 
  select(type, employee_id, test_score) %>% 
  arrange(type, desc(test_score))
s_manager
