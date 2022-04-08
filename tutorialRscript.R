# Created: 30 March 2022
# Updated: Several Times in March, 8 April, 2022
# Author: Anjali Silva (a.silva@utoronto.ca)
# Purpose: Getting Started with the Web of Science PostgreSQL Database

#### Tutorial Begins for Users ####

#### First login to SciNet and do this ####
# cd $HOME 
# module load gcc
# module load postgresql
# module load r/4.1.2
# R

# OR

# cd $HOME 
# module load gcc
# module load r/4.1.2
# singularity pull docker://rocker/tidyverse:4.1.3
# singularity exec tidyverse_4.1.3.sif R

#### Download R packages ####
install.packages("DBI")
library(DBI)
install.packages("dplyr")
library(dplyr)
install.packages("dbplyr")
library(dbplyr)
install.packages("RSQLite")
library(RSQLite)
install.packages("RPostgres")
library("RPostgres")
install.packages("magrittr")
library("magrittr")
install.packages("stringr")
library("stringr")

#### Get working directory ####
getwd()


#### Connecting to databases ####
db <- 'wos'  #provide the name of your db
hostdb <- 'idb1' 
dbWoS <- DBI::dbConnect(RPostgres::Postgres(), 
                 dbname = db, 
                 host = hostdb)  
# Let’s take a closer look at the mammals database we just connected to
dbplyr::src_dbi(dbWoS)
# src:  postgres  [asilva@idb1:5432/wos]
# tbls: abstract, address, author, author_address, conference,
# conference_sponsor, contributor, descriptor, funding, identifier, openaccess,
# publication, publication_conference, publication_descriptor, publisher,
# reference, reference_context, reference_patent, reference_unindexed, source

#### Querying the database with the dplyr syntax ####
# https://datacarpentry.org/R-ecology-lesson/05-r-and-databases.html

#### Searches: ####
# a.1. Search by Title
# Let’s find publications that have the words “visualization”. Type

searchWords <- c("visualization")
pubSearchA1 <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::select(title) %>%
  dplyr::filter(grepl(searchWords, title))

# a.2. Let’s find publications that have the words “visualization”, and 
# “library” OR “libraries” OR “librarian” in the title. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchA2 <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::select(title) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title))


# b.Search by Title words and Year (paste version):
# We can also limit searches based on multiple criteria for different fields. 
# Let’s run the same search as above, but limit it to only publications 
# published later than 2015. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchB <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::select(title, year) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2015")


# c.1. Search by Title words and Year, return specific fields:
# We have been selecting few fields in the publication table, but we can instead
# select several fields (type, year, title, ref_count) from the publication 
# table. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchC1 <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::select(type, year, title, ref_count) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2015")


# c.2.
# We have been selecting few fields in the publication table, but we can instead
# select all fields in the publication table. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchC2 <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::select(edition, source_id, type, year, month, day, vol,
                issue, page_begin, page_end, page_count, title, ref_count) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2015")


# d. Search by Title words and Year, but return Author information as well 
# So far these queries have focused on returning data from one table, but
# you can join tables to get information from multiple tables, such as
# publication and author. Let’s run the same search from above, 
# but also get author names included in the results. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchD <- dplyr::tbl(dbWoS, c("publication", "author")) %>%
  dplyr::select(year, title, full_name) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2015")

# (Note: This will result in publication titles being duplicated if there are
# multiple authors to list)


# e. Search by Title words and Year, but return Author and Source information as well
# You can join one table to more than one other table to pull in more  
# information into your results. Let’s run the query from example d, 
# but add the journal information as well. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchE <- dplyr::tbl(dbWoS, c("publication", "author", "source")) %>%
  dplyr::select(year, title, full_name, name) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2015")

# f. Search by Title words, Year and Author name (paste version):  
# You can also limit searches based on information in these multiple 
# tables. Let’s run the same search from above, but also limit to only 
# authors with the last name “Reid”. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchF <- dplyr::tbl(dbWoS, c("publication", "author", "source")) %>%
  dplyr::select(year, title, full_name, name) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(grepl("Reid", full_name)) %>%
  dplyr::filter(year > "2015")


# g. Search by Year and Source name (paste version):
# This can continue to get more complicated. You might want to join a table
# in order to query a field, but aren’t interested in including the data from
# that table in the final results. Note you could construct
# a query similar to example f above, the only difference is that the columns
# from the source table are not included here, but are included in example f.
# For this example, let’s query the database to find all recent publications 
# with author information for publications from the journal called 
# “Scientometrics”. This query finds all the source IDs where
# the source name is “Scientometrics” then filters publications that have that 
# source ID, plus the other criteria outlined below. Type

pubSearchG <- dplyr::tbl(dbWoS, c("publication", "author", "source")) %>%
  dplyr::select(year, title, full_name, name) %>%
  dplyr::filter(name == toupper("Scientometrics")) %>%
  dplyr::filter(year > "2019") %>%
  dplyr::select(-name)
 

# h. Search by Title words, Year and Author institution (paste version):  
# Some tables in the database are bridging tables, where there are many-to-one
# relationships, such as an author having many addresses. Let’s query the 
# database to find all publications with the word “visualization” in the title,
# published in the last couple of years from authors from the University of 
# Toronto. First you find all the address IDs that are for the University of 
# Toronto, then you find all the author IDs that have those address IDs, and
# then filter by those authors, plus the other criteria outlined below. (Note: 
# Just to simplify the query and make it run faster for this example, we're
# just looking for addresses with "Univ Toronto". Type  
  
searchWords <- c("visualization")
pubSearchH <- dplyr::tbl(dbWoS, 
  c("publication", "author", "address")) %>%
  dplyr::select(year, title, full_name, address) %>%
  dplyr::filter(grepl(searchWords, title)) %>%
  dplyr::filter(year > "2019") %>%
  dplyr::filter(grepl("Univ Toronto", address))


# i. Search by Keywords and Year (paste version):
# Here we are using another bridging table, this time to find publications
# based on a particular descriptor, such as a subject or keyword. This example
# is similar to the one above except searching by Keywords Plus (standardized
# keywords in the Web of Science dataset) instead of author affiliation. Let’s
# query the database to find all publications from 2020 that have a Keywords 
# Plus field roughly equal to “Artificial Intelligence”. Type 

pubSearchI <- dplyr::tbl(dbWoS, c("publication", "descriptor")) %>%
  dplyr::select(year, title, text) %>%
  dplyr::filter(year == "2020") %>%
  dplyr::filter(text == "Artificial Intelligence")


# j. Search by Title words and Year, returning only publication title 
# and abstract (paste version):  
# One useful field for text analysis that we haven't seen in our examples 
# yet would be to obtain abstracts for the items found. Let’s run a search 
# with similar search parameters to example b, but return titles and 
# abstracts only. Type
  
searchWords <- c("visualization", "library", "libraries", "librarian")
pubSearchJ <- dplyr::tbl(dbWoS, c("abstract", "publication")) %>%
  dplyr::select(title, year, text) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2019")


# k. Search for articles that cite a subset of articles (paste version):
# The Web of Science dataset is very valuable to analyze citation networks. 
# For example, we can use another bridging table called references to find 
# all publication IDs that cited or are cited by other publication IDs. 
# Let’s query the database to find all the articles that cite a (very small)
# subset of items. The subset is similar to example b above, find all articles
# that have the words “visualization”, and “library” OR “libraries” OR 
# “librarian” in the title, but this time only published after 2019. These
# types of queries are intensive and can take a while to run, so this is a
# very simple and small example to get you started. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
# First create the subset
pubSuset <- dplyr::tbl(dbWoS, c("publication")) %>%
  dplyr::select(title, year, id) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2019") %>%
  dplyr::pull(id) 
# Search the subset publication id in citing_id
pubSearchK <- dplyr::tbl(dbWoS, c("publication", "reference")) %>%
  dplyr::select(title, year, citing_id) %>%
  dplyr::filter(.data[["citing_id"]] %in% pubSuset)


# l. Search for articles that are cited by a subset of articles (paste version):  
# We can also query this the opposite way to find articles cited by a subset
# of articles. Let’s query the database to find all the articles that are 
# cited by a (very small) subset of items. The subset is the same as in 
# example k, and the modifications to the query in example k are minimal. Type

searchWords <- c("visualization", "library", "libraries", "librarian")
# First create the subset
pubSuset <- dplyr::tbl(dbWoS, c("publication")) %>%
  dplyr::select(title, year, id) %>%
  dplyr::filter(grepl(stringr::str_flatten(searchWords, collapse="|"), title)) %>%
  dplyr::filter(year > "2019") %>%
  dplyr::pull(id) 
# Search the subset publication id in cited_ids
pubSearchL <- dplyr::tbl(dbWoS, c("publication", "reference")) %>%
  dplyr::select(title, year, cited_id) %>%
  dplyr::filter(.data[["cited_id"]] %in% pubSuset)


#### To save results ####
# These files will be saved to $HOME

# To save a specific object, pubSearchJ, to a file rds
saveRDS(pubSearchJ, file = paste0("pubSearchJDate",Sys.Date(),".rds"))

# To save a specific object, pubSearchJ, to a file csv
save.csv(pubSearchJ, file = paste0("pubSearchJDate",Sys.Date(),".csv"))

# To save the entire workspace image
save.image(file = paste0("WoSQueryDate",Sys.Date(),".RData"))

# Enter 'q()' at prompt to quit R. 
# If you would like to 'Save workspace image?', press 'y'.


# [END]