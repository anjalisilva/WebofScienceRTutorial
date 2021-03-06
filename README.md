
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Getting Started with the Web of Science PostgreSQL Database for University of Toronto Using R Language

Accessing the Database via High Performance Computing Environment
Available on SciNet

<!-- badges: start -->
<!-- https://www.codefactor.io/repository/github/anjalisilva/MPLNClust/issues -->
<!-- [![CodeFactor](https://www.codefactor.io/repository/github/anjalisilva/mplnclust/badge)](https://www.codefactor.io/repository/github/anjalisilva/mplnclust)-->

[![GitHub
issues](https://img.shields.io/github/issues/anjalisilva/WebofScienceRTutorial)](https://github.com/anjalisilva/WebofScienceRTutorial/issues)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
![GitHub language
count](https://img.shields.io/github/languages/count/anjalisilva/WebofScienceRTutorial)
![GitHub commit activity
(branch)](https://img.shields.io/github/commit-activity/y/anjalisilva/WebofScienceRTutorial)

<!-- https://shields.io/category/license -->
<!-- badges: end -->

## Introduction

This tutorial will help querying the Web of Science (WoS) PostgreSQL
database for University of Toronto users. The tutorial closely follows
SQL and Python tutorials outlined by [University of Toronto Map and Data
Library](https://mdl.library.utoronto.ca/technology/tutorials/getting-started-web-science-postgresql-database-MAC).
Users will need access to the high performance computing environment on
SciNet for querying the WoS database. Instructions for accessing SciNet
are outlined by [University of Toronto
Library](https://mdl.library.utoronto.ca/technology/tutorials/how-access-web-science-postgresql-database).
R script of this entire tutorial (tutorialRscript.R), R script of one
search as an example (exampleSearchERScript.R), and the PDF document of
this tutorial (tutorialPDFdocument.PDF) are available on this
repository. Note, all results are based on WoS data as of 13 April 2022.

## Login to SciNet, install modules and open R

To install needed modules and open R there are two options as shown
below:

``` bash
cd $HOME 
module load gcc
module load postgresql
module load r/4.1.2
R

# OR

cd $HOME 
module load gcc
module load r/4.1.2
singularity pull docker://rocker/tidyverse:4.1.3
singularity exec tidyverse_4.1.3.sif R
```

## Download R packages

Now that R is opened, download the needed R packages. Once downloaded,
attach each package to current session using command library.

``` r
install.packages(c("DBI", 
                   "dbplyr", 
                   "RPostgres", 
                   "magrittr"))
library("DBI")
library("dbplyr")
library("RPostgres")
library("magrittr")
```

## Connecting to database on R

We will connect to WoS database using R package `DBI` and using function
dbConnect(). Anything followed by a hashtag is a comment in R.

``` r
db <- 'wos'  # provide the name of database
hostdb <- 'idb1' # host name
dbWoS <- DBI::dbConnect(RPostgres::Postgres(), 
                 dbname = db, 
                 host = hostdb)  
# Let???s take a closer look at the database
DBI::dbListTables(dbWoS)

# Determine how many tables
length(dbListTables(dbWoS)) # 20 different tables
```

## Getting help with R

If you are unclear of any function used, you may type `?` followed by
function name to pull up the help documentation. Another option is to
use help() function. Both options are shown below. On terminal, press
???q??? to quit help documentation.

``` r
?DBI::dbConnect

# OR

help(dbConnect, package = "DBI")
```

## a. Search by Title

Let???s find publications that have the word ???visualization???. Type

``` r
pubSearchA1 <- dplyr::tbl(dbWoS, "publication") %>% # access publication
  dplyr::filter(grepl("visualization", title, ignore.case = TRUE)) %>% # filter title for search word
  dplyr::collect() # retrieves data into a local tibble

# To get dimensions 
dim(pubSearchA1) 
# 59250 rows x 14 columns (as of 13 April 2022)
# 59250 publications contain search word visualization

# To access first publication  
pubSearchA1[1, ] 

# To see first few publications 
head(pubSearchA1)

# To see last few publications
tail(pubSearchA1)

# To see column names
colnames(pubSearchA1) # listing 14 column names 
# "id"         "edition"    "source_id"  "type"       "year"      
# "month"      "day"        "vol"        "issue"      "page_begin"
# "page_end"   "page_count" "title"      "ref_count" 
```

Another way to do the same search as above, to find publications that
have the words ???visualization???. Type

``` r
pubSearchA2 <- dplyr::tbl(dbWoS, "publication") %>% # access publication
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search word; 'ilike' for case-insensitive
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchA2) # dimensions: 59250 rows x 14 columns 

colnames(pubSearchA2) 
# "id"         "edition"    "source_id"  "type"       "year"      
# "month"      "day"        "vol"        "issue"      "page_begin"
# "page_end"   "page_count" "title"      "ref_count"

```

Let???s find publications that have the words ???visualization???, and
???library??? OR ???libraries??? OR ???librarian??? in the title. Type

``` r
pubSearchA3 <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchA3) # dimensions: 145 rows x 14 columns 
# 145 publications 

colnames(pubSearchA3)
# "id"         "edition"    "source_id"  "type"       "year" "month" "day" 
# "vol"        "issue"      "page_begin" "page_end"   "page_count" "title" 
# "ref_count" 
```

## b. Search by Title words and Year

We can also limit searches based on multiple criteria for different
fields. Let???s run the same search as above, but limit it to only
publications published later than 2015. Type

``` r
pubSearchB <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > "2015") %>%
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchB) # dimensions: 65 rows x 14 columns
# 65 publications 

colnames(pubSearchB)
# "id"         "edition"    "source_id"  "type"       "year"  "month" "day"
# "vol"        "issue"      "page_begin" "page_end"   "page_count" "title"
# "ref_count"
```

## c.??Search by Title words and Year, return specific fields only

We have been selecting all the fields in the publication table, but we
can instead only pick the ones of interest. Let???s only output the
publication title and year. Type

``` r
pubSearchC <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > 2015) %>% # filter for years
  dplyr::select(year, title) %>% # output only publication title and year
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchC) # dimensions: 65 rows x 2 columns 
# 65 publications and 2 columns: year and title

colnames(pubSearchC)
# "year"  "title"
```

## d.??Search by Title words and Year, but return Author information as well

So far these queries have focused on returning data from one table, but
you can join tables to get information from multiple tables, such as
publication and author. Let???s run the same search from above, but also
get author names included in the results. Type

``` r
pubSearchD <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::inner_join(dplyr::tbl(dbWoS,"author"), by = c("id"="wos_id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > 2015) %>% # filter for years
  dplyr::collect() # retrieves data into a local tibble

# (Note: This will result in publication titles being duplicated if there are multiple authors to list)

dim(pubSearchD) # dimensions: 441 rows x 20 columns 

colnames(pubSearchD) # listing 20 column names 
# "id.x"       "edition"    "source_id"  "type"       "year"      
# "month"   "day"        "vol"        "issue"      "page_begin" 
# "page_end""page_count" "title"      "ref_count"  "id.y" "full_name"  
# "seq_no"   "reprint"    "email"      "orcid"

# Note: This will result in publication titles being duplicated if there are multiple authors to list.
```

## e. Search by Title words and Year, but return Author and Source information as well

You can join one table to more than one other table to pull in more
information into your results. Let???s run the query from example d, but
add the journal information as well. Type

``` r
pubSearchE <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::inner_join(dplyr::tbl(dbWoS,"author"), by = c("id"="wos_id")) %>%
  dplyr::inner_join(dplyr::tbl(dbWoS,"source"), by = c("source_id"="id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > 2015) %>% # filter for years
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchE) # dimensions: 441 rows x 24 columns

colnames(pubSearchE) # listing 24 column names 
# "id.x" "edition"      "source_id"    "type"  "year"   "month"  "day"  
# "vol" "issue"        "page_begin" "page_end"     "page_count"   "title"
# "ref_count"    "id.y" "full_name"    "seq_no"       "reprint"      "email"
# "orcid"  "name"  "publisher_id" "abbrev"       "series"
```

## f.??Search by Title words, Year and Author name

You can also limit searches based on information in these multiple
tables. Let???s run the same search from above, but also limit to only
authors with the last name ???Reid???. Type

``` r
pubSearchF <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::inner_join(dplyr::tbl(dbWoS,"author"), by = c("id"="wos_id")) %>%
  dplyr::inner_join(dplyr::tbl(dbWoS,"source"), by = c("source_id"="id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(full_name %ilike% "Reid, %") %>% # filter for search words
  dplyr::filter(year > 2015) %>% # filter for years
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchF) # dimensions: 1 row x 24 columns

colnames(pubSearchF)
# "id.x" "edition" "source_id" "type" "year"  "month" "day" "vol" "issue" "page_begin"
# "page_end" "page_count" "title" "ref_count" "id.y" "full_name" "seq_no" "reprint"  
# "email"  "orcid" "name" "publisher_id" "abbrev"  "series"   
```

## g. Search by Year and Source name

This can continue to get more complicated. You might want to join a
table in order to query a field, but aren???t interested in including the
data from that table in the final results. Note you could construct a
query similar to example f above, the only difference is that the
columns from the source table are not included here, but are included in
example f.??For this example, let???s query the database to find all recent
publications with author information for publications from the journal
called ???Scientometrics???. This query finds all the source IDs where the
source name is ???Scientometrics??? then filters publications that have that
source ID, plus the other criteria outlined below. Type

``` r
pubSearchG <- dplyr::tbl(dbWoS, "source") %>%  
  dplyr::filter(name %ilike% "%Scientometrics%") %>% # filter for source name
  dplyr::select(id) %>% # select source IDs where source name is "Scientometrics"
  dplyr::left_join(dplyr::tbl(dbWoS,"publication"), by = c("id"="source_id")) %>%
  dplyr::left_join(dplyr::tbl(dbWoS,"author"), by = c("id.y"="wos_id")) %>%
  dplyr::filter(year > "2019") %>%
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchG) # dimensions: 3536 rows x 20 columns

colnames(pubSearchG)
# "id.x" "id.y" "edition" "type" "year"  "month" "day" "vol" "issue" "page_begin" 
# "page_end" "page_count" "title" "ref_count"  "id"        "full_name"  "seq_no"     
# "reprint"    "email"      "orcid" 
```

## h. Search by Title words, Year and Author institution

Some tables in the database are bridging tables, where there are
many-to-one relationships, such as an author having many addresses.
Let???s query the database to find all publications with the word
???visualization??? in the title, published in the last couple of years from
authors from the University of Toronto. First you find all the address
IDs that are for the University of Toronto, then you find all the author
IDs that have those address IDs, and then filter by those authors, plus
the other criteria outlined below. (Note: Just to simplify the query and
make it run faster for this example, we???re just looking for addresses
with ???Univ Toronto???. Type

``` r
pubSearchH <- dplyr::tbl(dbWoS, "address") %>%  
  dplyr::filter(address %ilike% "%Univ Toronto%") %>% # filter for UofT
  dplyr::select(id) %>% # select address IDs that are for UofT
  dplyr::left_join(dplyr::tbl(dbWoS,"author"), by = c("id"="id")) %>%
  dplyr::left_join(dplyr::tbl(dbWoS,"publication"), by = c("id"="source_id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(year > "2019") %>%
  dplyr::select(title, full_name) %>% # select address IDs that are for UofT
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchH) # dimensions: 0 rows x 2 columns

colnames(pubSearchH)
# "title"     "full_name"
```

## i. Search by Keywords and Year

Here we are using another bridging table, this time to find publications
based on a particular descriptor, such as a subject or keyword. This
example is similar to the one above except searching by Keywords Plus
(standardized keywords in the Web of Science dataset) instead of author
affiliation. Let???s query the database to find all publications from 2020
that have a Keywords Plus field roughly equal to ???Artificial
Intelligence???. Type

``` r
pubSearchI <- dplyr::tbl(dbWoS, "descriptor") %>% 
  dplyr::filter(text %ilike% "%Artificial Intelligence%") %>% # filter for UofT
  dplyr::filter(type == "kw_plus") %>% 
  dplyr::select(id) %>% # select address IDs that are for UofT
  dplyr::left_join(dplyr::tbl(dbWoS,"publication_descriptor"), by = c("id"="desc_id")) %>%
  dplyr::select(wos_id) %>% 
  dplyr::left_join(dplyr::tbl(dbWoS,"publication"), by = c("wos_id"="id")) %>%
  dplyr::filter(year == "2020") %>%
  dplyr::select(year, title) %>%
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchI) # dimensions: 2 rows x 2 columns

colnames(pubSearchI)
# "wos_id" "edition" "source_id" "type" "year" "month" "day" "vol"        
# "issue" "page_begin" "page_end"   "page_count" "title" "ref_count" 
```

## j. Search by Title words and Year, returning only publication title and abstract

One useful field for text analysis that we haven???t seen in our examples
yet would be to obtain abstracts for the items found. Let???s run a search
with similar search parameters to example b, but return titles and
abstracts only. Type

``` r
pubSearchJ <- dplyr::tbl(dbWoS, "publication") %>%
  dplyr::inner_join(dplyr::tbl(dbWoS,"abstract"), by = c("id"="wos_id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > 2019) %>% # filter for years
  dplyr::select(title, text) %>% # select only title and text 
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchJ) # dimensions: 20 rows x 2 columns

colnames(pubSearchJ)
# "title"     "full_name"
```

## k. Search for articles that cite a subset of articles

The Web of Science dataset is very valuable to analyze citation
networks. For example, we can use another bridging table called
references to find all publication IDs that cited or are cited by other
publication IDs. Let???s query the database to find all the articles that
cite a (very small) subset of items. The subset is similar to example b
above, find all articles that have the words ???visualization???, and
???library??? OR ???libraries??? OR ???librarian??? in the title, but this time only
published after 2019. These types of queries are intensive and can take
a while to run, so this is a very simple and small example to get you
started. Type

``` r
pubSearchK <- dplyr::tbl(dbWoS, "reference") %>%  
  dplyr::inner_join(dplyr::tbl(dbWoS,"publication"), by = c("cited_id"="id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > "2019") %>%
  dplyr::select(citing_id) %>%
  dplyr::left_join(dplyr::tbl(dbWoS,"publication"), by = c("citing_id"="id")) %>%
  dplyr::select(title) %>% # 
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchK) # dimensions: 40 rows x 1 columns

colnames(pubSearchK)
# "title"
```

## l. Search for articles that are cited by a subset of articles

We can also query this the opposite way to find articles cited by a
subset of articles. Let???s query the database to find all the articles
that are cited by a (very small) subset of items. The subset is the same
as in example k, and the modifications to the query in example k are
minimal. Type

``` r
pubSearchL <- dplyr::tbl(dbWoS, "reference") %>%  
  dplyr::inner_join(dplyr::tbl(dbWoS,"publication"), by = c("citing_id"="id")) %>%
  dplyr::filter(title %ilike% "%visualization%") %>% # filter for search words
  dplyr::filter(title %ilike% "%librar%") %>% # filter for search words
  dplyr::filter(year > "2019") %>%
  dplyr::select(cited_id) %>%
  dplyr::left_join(dplyr::tbl(dbWoS,"publication"), by = c("cited_id"="id")) %>%
  dplyr::select(title) %>% # 
  dplyr::collect() # retrieves data into a local tibble

dim(pubSearchL) # dimensions: 348 rows x 1 columns

colnames(pubSearchL)
# "title"
```

## To save results and quit R

These files will be saved to $HOME

``` r
# To save a specific object, pubSearchJ, to a file rds
saveRDS(pubSearchJ, file = paste0("pubSearchJDate", Sys.Date(), ".rds"))

# To save a specific object, pubSearchJ, to a file csv
save.csv(pubSearchJ, file = paste0("pubSearchJDate", Sys.Date(), ".csv"))

# To save the entire workspace image
save.image(file = paste0("WoSQueryDate", Sys.Date(), ".RData"))

q() # Enter q() at prompt to quit R
# If you would like to 'Save workspace image?', press 'y'.

# If a search is taking too long, you may save the search into an
# R script of its own, save it with a name (e.g., 
# exampleSearchERScript.R) and run it from $HOME, using command 
# Rscript exampleSearchERScript.R. A example of such a script for
# search E is provided in this repository, called exampleSearchERScript.R.
Rscript exampleSearchERScript.R

# [END] 
```

## Maintainer

Anjali Silva (<a.silva@utorontoca>). Last updated 18 April 2022.

## Contributions

This tutorial welcomes issues, enhancement requests, and other
contributions. To submit an issue, use the [GitHub
issues](https://github.com/anjalisilva/WebofScienceRTutorial/issues).

## Acknowledgments

SciNet HPC Consortium, University of Toronto, ON, Canada for all the
SciNet setup support. This tutorial closely follows SQL and Python
tutorials outlined by [University of Toronto Map and Data
Library](https://mdl.library.utoronto.ca/technology/tutorials/getting-started-web-science-postgresql-database-MAC),
University of Toronto, ON, Canada.
