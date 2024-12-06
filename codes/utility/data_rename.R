args = commandArgs(trailingOnly=TRUE)
setwd(args[1])

#setwd("C:/Ourfolders/Aly/MK_WB/data/processed")


library(dplyr)

data <- data.table::fread("MK_202212_processed.csv",
                              header = TRUE, keepLeadingZeros = TRUE, encoding = "UTF-8",
                              stringsAsFactors = FALSE,showProgress = TRUE, 
                              na.strings = c("", "-", "NA"))

#data_raw <- data.table::fread("../raw//MK_202211_20221125/MK_data_202211.csv",
#                          header = TRUE, keepLeadingZeros = TRUE, encoding = "UTF-8",
#                          stringsAsFactors = FALSE,showProgress = TRUE, 
#                          na.strings = c("", "-", "NA"))

colnames(data)
#colnames(data_raw)
data <- data %>% rename(tender_publications_lastcallfortenderdate=tender_publications_lastcallfort,
                        tender_publications_lastcontractawardurl=tender_publications_lastcontract,
                        tender_publications_firstcallfortenderdate=tender_publications_firstcallfor,
                        tender_publications_firstcontractawarddate=tender_publications_firstcontrac,
                        tender_addressofimplementation_nuts=tender_addressofimplementation_n)

data.table::fwrite(data, "MK_202211_processed.csv",
                   quote = TRUE, sep = "," )

rm(data_raw)
rm(data)
