#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

#setwd("C:/Ourfolders/Aly/MK_WB/data/processed")


#Code returns region based on city name

library(dplyr)
library(data.table)

#api_key <- 'fHuenPNNnjgKVZGOTy9UQudJiwxBng_T7NV_roEJFEw'  #using rawda's mail
# api_key <- 'q2K5jolNQulfL-E7wbZtZ_mjMkwwGK4zeqlG5cvbrd4'   #using aly's mail
app_id <- 'oJYrZi7Q3DusxC4s2Mx3'
api_key <- '2lyXlCAma0jZeDECzxENRnh448rt6uyTB1hTSpcU-cE'   #using aly's mail

locations.get_url <- function(address_name, language, apiKey) {
  if (missing(language)) {
    language <- "en"
  } else {
    language <- tolower(language)
  }
  base_url <- "https://geocoder.ls.hereapi.com/6.2/geocode.json"
  base_url <- 'https://geocode.search.hereapi.com/v1/geocode.json'
  output <- httr::GET(base_url,
                      query = list(language = language,
                                   apiKey = api_key,
                                   # app_code = App_code,
                                   searchtext = address_name))
  return(output)
}


locations.response_url <- function(api_request) {
  # get the response of the link
  output <- httr::content(api_request)
  return(output)
}

locations.new_country <- function(api_response, address_name) {
  # takes the response link and returns the captured country name when available
  check <- api_response
  address <- address_name
  print(paste("input:",address, sep = " "))
  if (length(check[[1]][["Response"]][["View"]])>0|length(check[["Response"]][["View"]])>0) {
    try(Country <- check[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["Country"]])
    
    if (is.null(Country)==TRUE | length(Country)==0) {
      try(Country <- check[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["Country"]])
      return(Country)
    }
  }
}


locations.new_state <- function(api_response, address_name) {
  # takes the response link and returns the captured State name when available
  check <- api_response
  address <- address_name
  print(paste("input:",address, sep = " "))
  if (length(check[[1]][["Response"]][["View"]])>0|length(check[["Response"]][["View"]])>0) {
    try(State <- check[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["State"]])
    
    if (is.null(State)==TRUE | length(State)==0) {
      try(State <- check[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["State"]])
      return(State)
    }
  }
}

locations.new_county <- function(api_response, address_name) {
  # takes the response link and returns the captured County name when available
  check <- api_response
  address <- address_name
  print(paste("input:",address, sep = " "))
  if (length(check[[1]][["Response"]][["View"]])>0|length(check[["Response"]][["View"]])>0) {
    try(County <- check[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["County"]])
    
    if (is.null(County)==TRUE | length(County)==0) {
      try(County <- check[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["County"]])
      return(County)
    }
  }
}


locations.new_city <- function(api_response, address_name) {
  # takes the response link and returns the captured County name when available
  check <- api_response
  address <- address_name
  print(paste("input:",address, sep = " "))
  if (length(check[[1]][["Response"]][["View"]])>0|length(check[["Response"]][["View"]])>0) {
    try(City <- check[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]])
    
    if (is.null(City)==TRUE | length(City)==0) {
      try(City <- check[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]])
      return(City)
    }
  }
}

locations.new_district <- function(api_response, address_name) {
  # takes the response link and returns the captured County name when available
  check <- api_response
  address <- address_name
  print(paste("input:",address, sep = " "))
  if (length(check[[1]][["Response"]][["View"]])>0|length(check[["Response"]][["View"]])>0) {
    try(District <- check[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["District"]])
    
    if (is.null(District)==TRUE | length(District)==0) {
      try(District <- check[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["District"]])
      return(District)
    }
  }
}

locations.new_street <- function(api_response, address_name) {
  # takes the response link and returns the captured County name when available
  check <- api_response
  address <- address_name
  print(paste("input:",address, sep = " "))
  if (length(check[[1]][["Response"]][["View"]])>0|length(check[["Response"]][["View"]])>0) {
    try(Street <- check[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["Street"]])
    
    if (is.null(Street)==TRUE | length(Street)==0) {
      try(Street <- check[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["Street"]])
      return(Street)
    }
  }
}


##################################################################################################
#Read data
stata_city <- read.csv('stata_city.csv', header = TRUE, sep = ",",  encoding = "UTF-8")
#stata_city <- data.table::fread(file = 'stata_city.csv', 
#                             sep=",",
#                             encoding='UTF-8',
#                             header = TRUE)

sprintf("reading in %s", "stata_city.csv")
language <- args[2]

# Get the base URL
stata_city$base_url <- NA
stata_city$base_url <- lapply(X = stata_city$city_clean, 
                              FUN = locations.get_url,
                              language = language,
                              apiKey = api_key)
# Requesting the API response
stata_city$response <- NA
stata_city$response <- lapply(X = stata_city$base_url,
                              FUN = locations.response_url)
# Add country name

stata_city$country_api <- NA
stata_city$country_api <- mapply(FUN = locations.new_country,
                               api_response = stata_city[, "response"],
                               address = stata_city[, "city_clean"])
stata_city$country_api <- as.character(stata_city$country_api)

# Add state name

stata_city$state_api <- NA
stata_city$state_api <- mapply(FUN = locations.new_state,
                               api_response = stata_city[, "response"],
                               address = stata_city[, "city_clean"])
stata_city$state_api <- as.character(stata_city$state_api)

# Add county name

stata_city$county_api <- NA
stata_city$county_api <- mapply(FUN = locations.new_county,
                                api_response = stata_city[, "response"],
                                address = stata_city[, "city_clean"] )
stata_city$county_api <- as.character(stata_city$county_api)

# Add city name

stata_city$city_api <- NA
stata_city$city_api <- mapply(FUN = locations.new_city,
                              api_response = stata_city[, "response"],
                              address = stata_city[, "city_clean"])

stata_city$city_api <- as.character(stata_city$city_api)

# Add district name

stata_city$district_api <- NA
stata_city$district_api <- mapply(FUN = locations.new_district,
                              api_response = stata_city[, "response"],
                              address = stata_city[, "city_clean"])

stata_city$district_api <- as.character(stata_city$district_api)

# Add street name

stata_city$street_api <- NA
stata_city$street_api <- mapply(FUN = locations.new_street,
                                  api_response = stata_city[, "response"],
                                  address = stata_city[, "city_clean"])

stata_city$street_api <- as.character(stata_city$street_api)



stata_city <- stata_city %>% select(c("city","country","type","city_clean", 
                                      "country_api","state_api","county_api","city_api","district_api","street_api"))


data.table::fwrite(stata_city, paste0("MK_cities_api_",language,".csv"),
                   quote = TRUE, sep = "," )
##################################################################################################
# One record
x = "Boro Nawpara, Lohojang, Munshigonj."
language = "en"
baseurl  = locations.get_url(x,language, api_key)
# # # # #
output = locations.response_url(baseurl)
output
# district <- output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["District"]]
# city <- output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]]
# county <- output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["County"]]
# state <- output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["State"]]
# 
# print(paste("District:",district, sep = " "))
# print(paste("City:",city, sep = " "))
# print(paste("County:",county, sep = " "))
# print(paste("State:",state, sep = " "))
# print(paste("Street:",output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["Street"]], sep = " "))
# 



# #  
#output =  stata_city$response[1]
#  
#  print(locations.new_county(output, x))
#  print(locations.new_city(output, x))
#  print(locations.new_state(output, x))

# 
# output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]]
# 
# output[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]]
# 
# output[[1]][["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]]
# 
# 
# output[["Response"]][["View"]][[1]][["Result"]][[1]][["Location"]][["Address"]][["City"]]
# 
# output$Response$View[[1]]$Result[[1]]$Location$Address$City