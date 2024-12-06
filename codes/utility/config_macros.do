
*Macros
local dir : pwd
global data "`dir'/data"
global data_raw "`dir'/data/raw"
global data_processed "`dir'/data/processed"
global data_utility "`dir'/data/utility"

global output_figures "`dir'/output/figures"
global output_tables "`dir'/output/tables"
global output_log "`dir'/output/log"

global codes "`dir'/codes"
global codes_utility "`dir'/codes/utility"
global codes_scrap "`dir'/codes/scrap"

// Load config
qui import delimited "${data_utility}/config.csv", clear
levelsof v2 if v1=="R_path", local(R_path)
levelsof v2 if v1=="ftp_username", local(ftp_username)
levelsof v2 if v1=="ftp_password", local(ftp_password)

global R_path `R_path'
global ftp_username `ftp_username'
global ftp_password `ftp_password'
 
clear
