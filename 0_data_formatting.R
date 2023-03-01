#' Data taken from Axelar-Fact-Transfers 
#' and cleaned here with notes 

library(dplyr)

arbitrum <- read.csv("arbitrum_to_elsewhere.csv",colClasses = 'character', row.names = NULL)
arbitrum$sourcechain <- "arbitrum"

avax <- read.csv("avax_to_elsewhere.csv",colClasses = 'character', row.names = NULL)
avax$sourcechain <- "avalanche"

bsc <- read.csv("bsc_to_elsewhere.csv",colClasses = 'character', row.names = NULL)
bsc$sourcechain <- "binance"

eth <- read.csv("eth_to_elsewhere.csv",colClasses = 'character', row.names = NULL)
eth$sourcechain <- "ethereum"

polygon <- read.csv("polygon_to_elsewhere.csv",colClasses = 'character', row.names = NULL)
polygon$sourcechain <- "polygon"

evm <- rbind(eth, arbitrum, avax, bsc, polygon)

evm <- evm %>% mutate(
  destinationchain = 
    case_when( 
      tolower(DESTINATIONCHAIN) == 'arbitrum' ~ "arbitrum",
      tolower(DESTINATIONCHAIN) %in% c('avalanch', 'avalanche') ~ "avalanche",
      tolower(DESTINATIONCHAIN) %in% c('axelar','axelarnet') ~ "axelarnet",
      TRUE ~ tolower(DESTINATIONCHAIN)
               )
)

eoatbl <- as.data.frame(table(evm$EOA, evm$sourcechain, evm$destinationchain)) %>% 
  filter(Freq > 0)
colnames(eoatbl) <- c("address","sourcechain","destinationchain", "amount")

srcdest <- as.data.frame(table(evm$sourcechain, evm$destinationchain)) %>% 
  filter(Freq > 0)
colnames(srcdest) <- c("sourcechain","destinationchain", "amount")
