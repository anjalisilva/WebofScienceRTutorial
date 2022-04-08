# Created: 08 April 2022
# Author: Anjali Silva (a.silva@utoronto.ca)
# Purpose: Getting Started with the Web of Science PostgreSQL Database
#          Using R, doing search E using Rscript command


#### Download R packages ####
# install.packages(c("DBI", "dplyr", "dbplyr",
#                   "RSQLite", "RPostgres", 
#                   "magrittr", "stringr"))
library("DBI")
library("dplyr")
library("dbplyr")
library("RSQLite")
library("RPostgres")
library("magrittr")
library("stringr")

#### Connecting to databases ####
db <- 'wos'  # provide the name of data base
hostdb <- 'idb1' # host name
dbWoS <- DBI::dbConnect(RPostgres::Postgres(), 
                 dbname = db, 
                 host = hostdb)  
# Let’s take a closer look at the mammals database 
dbplyr::src_dbi(dbWoS)

#### Search E ####
# e. Search by Title words and Year, but return Author and Source information as well
# You can join one table to more than one other table to pull in more  
# information into your results. Let’s run the query from example d, 
# but add the journal information as well. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchE <- dplyr::tbl(dbWoS, c("publication", "author", "source")) %>%
  dplyr::select(year, title, full_name, name) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2015") %>%
  dplyr::collect() # retrieves data into a local tibble

#### To save results ####
# These files will be saved to $HOME
# To save a specific object, pubSearchJ, to a file rds
saveRDS(pubSearchE, file = paste0("pubSearchE", Sys.Date(), ".rds"))

# [END]