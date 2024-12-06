args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

print("Running code")

# Packages 
# Load and Install libraries ----

# FIRST: check if pacman is installed. 
# This package installs and loads other packages
if (!require(pacman)) {
  install.packages("pacman", dependencies = TRUE)
}

# SECOND: list all other packages that will be used
# Add libraries as needed here.
# Please also add the reason why this library is added
packages <- c(
  "here",
  "tidyverse", # general data wrangling
  "dplyr", # data manipulation
  "stringi", #string manipulation
  "foreign" # export dta file
) 

# THIRD: installing and loading the packages
# The following lines checks if the libraries are installed.
# If installed, they will be loaded.
# If not, they will be installed then loaded.
p_load(
  packages, 
  character.only = TRUE, 
  depencies = TRUE
)

options(warn=0) # suppress warnings OFF
####################################################################################
#Load PP Data  ----
file = "C:/Ourfolders/Aly/MK_WB/data/processed/MK_cpvs_to_fix.csv"
df <- data.table::fread(here(file),
                              header = TRUE, keepLeadingZeros = TRUE, encoding = "UTF-8",
                              stringsAsFactors = FALSE,showProgress = TRUE, 
                              na.strings = c("", "NA"))

#Load CPV data  ----

file = "C:/Ourfolders/Aly/MK_WB/data/utility/cpv_2007_translated.csv"
cpv <- data.table::fread(here(file),
                              header = TRUE, keepLeadingZeros = TRUE, encoding = "UTF-8",
                              stringsAsFactors = FALSE,showProgress = TRUE, 
                              na.strings = c("", "NA"))

## Load MK stop words
file = "C:/Ourfolders/Aly/MK_WB/data/utility/MK_stopwords.csv"
mk_stopwords <- data.table::fread(here(file),
                         header = TRUE, keepLeadingZeros = TRUE, encoding = "UTF-8",
                         stringsAsFactors = FALSE,showProgress = TRUE, 
                         na.strings = c("", "NA"))
mk_stopwords <- mk_stopwords$words
####################################################################################
# Clean search columns

#Create search text
df$title <- trimws(paste(df$tender_title, df$lot_title, sep = " "), "both")

# Create Market in cpv data
cpv$market_id <- substr(cpv$cpv_codes, start = 1, stop = 2)

# Convert title and tender_cpvs_new columns to lowercase
df$title <- str_to_lower(df$title)
cpv$cpv_desc_mk <- str_to_lower(cpv$cpv_desc_mk)

#Remove MK stop words from CPV and title columns in the pp data
for (word in mk_stopwords) {
  df$title <- gsub(paste0("\\b", word, "\\b"), "", df$title)
  cpv$cpv_desc_mk <- gsub(paste0("\\b", word, "\\b"), "", cpv$cpv_desc_mk)
}

# Remove all punct marks and replace them with space
cpv$cpv_desc_mk <- stri_replace_all_regex(cpv$cpv_desc_mk, "\\p{Punct}", " ")
df$title <- stri_replace_all_regex(df$title, "\\p{Punct}", " ")

####################################################################################
find_cpv_mk <- function(cpv_desc_mk, cpv_code, title) {
  # split cpv_desc_mk into a set of words
  #cpv_desc_words <- strsplit(cpv_desc_mk, split = " ")[[1]]
  cpv_desc_words <- stri_split_regex(cpv_desc_mk, "\\s+")[[1]]
  # split title into a set of words
  #title_words <- strsplit(title, split = " ")[[1]]
  title_words <- stri_split_regex(title, "\\s+")[[1]]
  
  # check if all cpv_desc_words are in the title_words
  if (all(cpv_desc_words %in% title_words)) {
    return(cpv_code)
  } else {
    return(NA)
  }
}

#find_cpv_mk(cpv_desc_mk, cpv_code, title)

#Create a filterd version of df withonly missing tender_cpvs
df_missing <- df %>% filter(is.na(tender_cpvs))
df_nomissing <- df %>% filter(!is.na(tender_cpvs))

# loop over rows and apply find_cpv_mk function to each row
start_time <- Sys.time()

for (i in 1:nrow(cpv)) {
  print(cpv$cpv_desc_mk[i])
  print(cpv$cpv_codes[i])
  cpv_desc_i =cpv$cpv_desc_mk[i]
  cpv_code_i =cpv$cpv_codes[i]
  #Apply function to all rows using cpv_desc_i and cpv_code_i
  df_missing$tender_cpvs_new <- mapply(find_cpv_mk,
                               cpv_desc_mk = cpv_desc_i,
                               cpv_code = cpv_code_i,
                               title = df_missing$title)
  end_time <- Sys.time()
  elapsed_time <- difftime(end_time, start_time, units = "mins")
  cat("Elapsed time:", as.numeric(elapsed_time), "minutes")
  
}
#Export Datasets
file = "C:/Ourfolders/Aly/MK_WB/data/processed/MK_cpvs_df_missing.csv"
data.table::fwrite(df_missing, file,
                   quote = TRUE, sep = "," )

df_combined <- rbind(df_nonmissing, df_missing)
rm(df_nonmissing, df_missing)
####################################################################################
####################################################################################
####################################################################################
# Fuzzy match 1 
library(fuzzyjoin)

# define the matching criteria and string distance method
threshold <- 0.9
method <- "jw"

# perform a fuzzy join between cpv$cpv_desc_mk and df$title
matches <- stringdist_left_join(cpv, df, by = c("cpv_desc_mk" = "title"),
                                max_dist = threshold, method = method)

# get the indexes of the matched data in the cpv dataframe
matched_indexes <- matches$cpv_codes[!is.na(matches$cpv_codes)]

# Fuzzy 2 
library(fuzzyjoin)
library(tidyverse)

# create a function to calculate match scores
get_match_score <- function(x, y) {
  stringdist(x, y, method = "jw") # using Jaro-Winkler method for string distance
}

# perform fuzzy match between cpv$cpv_desc_mk and df$title columns
matched_data <- stringdist_inner_join(cpv, df, by = c("cpv_desc_mk" = "title"), method = get_match_score) %>%
  filter(stringdist < 0.2) # filter out low match scores

# print the matched data
matched_data


####################################################################################
####################################################################################
####################################################################################


# Define a function to remove the most frequent words
remove_common_words <- function(text, freq_words) {
  # Convert text to lowercase
  text <- tolower(text)
  # Remove punctuation
  text <- gsub("[[:punct:]]", " ", text)
  # Split text into individual words
  words <- strsplit(text, "\\s+")
  # Remove common words
  words <- words[[1]][!words[[1]] %in% freq_words]
  # Paste remaining words back together
  text <- paste(words, collapse = " ")
  # Trim whitespace
  text <- trimws(text)
  return(text)
}

# Load the data
data <- read.csv("your_data.csv")

# Get the most frequent words in each market_id
market_words <- data %>%
  group_by(market_id) %>%
  summarize(title = paste(tender_title, collapse = " ")) %>%
  mutate(title = remove_common_words(title, stopwords("english"))) %>%
  unnest_tokens(word, title) %>%
  count(market_id, word, sort = TRUE) %>%
  group_by(market_id) %>%
  top_n(10)

# Define a function to assign market_id based on keyword matching
assign_market_id <- function(text, market_words) {
  # Convert text to lowercase
  text <- tolower(text)
  # Remove punctuation
  text <- gsub("[[:punct:]]", " ", text)
  # Split text into individual words
  words <- strsplit(text, "\\s+")
  # Check if any of the market keywords are present in the text
  matches <- market_words$word[market_words$market_id == unique(data$market_id)[match(TRUE, sapply(unique(data$market_id), function(x) x %in% market_words$market_id))]] %in% unlist(words)
  # If there's a match, return the corresponding market_id, otherwise return NA
  if (any(matches)) {
    return(market_words$market_id[market_words$word %in% market_words$word[matches]][1])
  } else {
    return(NA)
  }
}

# Remove the most frequent words from the tender_title column
data$tender_title <- remove_common_words(data$tender_title, stopwords("english"))

# Assign market_id to rows missing market_id
data$market_id <- ifelse(is.na(data$market_id), sapply(data$tender_title, assign_market_id, market_words), data$market_id)

# Save the updated data
write.csv(data, "updated_data.csv", row.names = FALSE)



This code assumes that you have a CSV file called "your_data.csv" in your working directory that contains a column called "tender_title" and a column called "market_id". It uses the dplyr package for data manipulation and the tidytext package for text preprocessing and tokenization.

The first part of the code defines a function called remove_common_words that removes the most frequent English words from a given text string. This function will be used later to clean up the tender_title column.

The next part of the code loads the data and groups it by market_id to get the most frequent words in each market. It uses the stopwords function from the tidytext package to remove common English words from the titles before counting the remaining words. It then selects the top 10 words for each market_id.

The third part of the code defines a function called assign_market_id that takes a text string and a data






