# Synthetic Axelar Data

# Address Reference Table:
#   osmosis_address | EVM_address | unique_crosschain_userID
# osmo1bobby      | 0xb0bb      | osmos1bobby--0xb0bb
# NULL            | 0xa11ce     | --0xa11ce
# Node Table:
#   id | label | coordinate-x | coordinate-y | hover-title | shape-or-image
# 1  | Osmosis  | -5         |  5           | <h1>OSMO<h2> | osmosis_logo.png
# 2  | Ethereum | 0          |  2           | <h1>ETH<h2>  | eth_logo.png
# 3  | Polygon  | 1          |  5           | <h1>MATIC<h2>| matic_logo.png
# Edges Table:
#   unique_crosschain_userID | from | to | numtransfers | total_value_transferred
# --0xa11ce           | Polygon | Ethereum  | 25 | 2,525
# osmos1bobby--0xb0bb | Ethereum | Polygon  | 10 | 15,405
# osmos1bobby--0xb0bb | Polygon  | Osmosis  | 6  | 35,430
# osmos1bobby--0xb0bb | Osmosis  | Ethereum | 3  | 2,320

set.seed(4)
chains <- c("Ethereum","Binance","Avalanche","Polygon","Osmosis","Axelar", "Juno")

evm_chains <- c("Ethereum","Binance","Avalanche","Polygon")

tokens <- c("AXL","AXLUSDC","USDC", "WETH","WAVAX","OSMO","WMATIC")
evm_addresses <- paste0("0x",
                        replicate(100,
                                  paste0(sample(c(0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f"), size = 20, replace = TRUE),
                                         collapse = "")))
osmo_addresses <- paste0("osmo1",
                         replicate(100,
                                   paste0(sample(LETTERS, size = 20, replace = TRUE),
                                          collapse = "")))

axl_addresses <- paste0("axl",
                        replicate(100,
                                  paste0(sample(LETTERS, size = 20, replace = TRUE),
                                         collapse = "")))

juno_addresses <- paste0("juno",
                         replicate(100,
                                   paste0(sample(LETTERS, size = 20, replace = TRUE),
                                          collapse = "")))

amounts <- ceiling(abs(rnorm(10000, 100, sd = 100)))

sourcechain <- sample(chains,
                       size = 10000,
                       replace = TRUE,
                       prob = c(.25, .1,.1,.15,.25,.1,.05))


destchain <- sample(chains,
                       size = 10000,
                       replace = TRUE,
                       prob = c(.25, .1,.1,.15,.25,.1,.05))

transfer_sim <- data.frame(
  srcchain = sourcechain,
  token = sample(tokens, 10000, replace = TRUE, prob = c(0.05, 0.5, 0.05, 0.25, 0.05, 0.05, 0.05)),
  amount = amounts,
  destchain = destchain
)

transfer_sim <- transfer_sim[transfer_sim$srcchain != transfer_sim$destchain, ]

transfer_sim$srcaddress <- NA
transfer_sim$destaddress <- NA

# evm
nevm <- sum(transfer_sim$srcchain %in% evm_chains)
transfer_sim[transfer_sim$srcchain %in% evm_chains, "srcaddress"] <- {
  sample(evm_addresses, size = nevm, replace = TRUE)
}
nevmd <- sum(transfer_sim$destchain %in% evm_chains)
transfer_sim[transfer_sim$destchain %in% evm_chains, "destaddress"] <- {
  sample(evm_addresses, size = nevmd, replace = TRUE)
}

# osmosis
nosmos <- sum(transfer_sim$srcchain %in% c("Osmosis"))
transfer_sim[transfer_sim$srcchain %in% c("Osmosis"), "srcaddress"] <- {
  sample(osmo_addresses, size = nosmos, replace = TRUE)
}
nosmosd <- sum(transfer_sim$destchain %in% c("Osmosis"))
transfer_sim[transfer_sim$destchain %in% c("Osmosis"), "destaddress"] <- {
  sample(osmo_addresses, size = nosmosd, replace = TRUE)
}

#axl
naxl <- sum(transfer_sim$srcchain %in% c("Axelar"))
transfer_sim[transfer_sim$srcchain %in% c("Axelar"), "srcaddress"] <- {
  sample(axl_addresses, size = naxl, replace = TRUE)
}

naxld <- sum(transfer_sim$destchain %in% c("Axelar"))
transfer_sim[transfer_sim$destchain %in% c("Axelar"), "destaddress"] <- {
  sample(axl_addresses, size = naxld, replace = TRUE)
}

#juno
njuno <- sum(transfer_sim$srcchain %in% c("Juno"))
transfer_sim[transfer_sim$srcchain %in% c("Juno"), "srcaddress"] <- {
  sample(juno_addresses, size = njuno, replace = TRUE)
}

njunod <- sum(transfer_sim$destchain %in% c("Juno"))
transfer_sim[transfer_sim$destchain %in% c("Juno"), "destaddress"] <- {
  sample(juno_addresses, size = njunod, replace = TRUE)
}

# Fixes

#EVMs transfer to same address on EVM chains
transfer_sim[transfer_sim$srcchain %in% evm_chains & transfer_sim$destchain %in% evm_chains, "destaddress"] <-
  transfer_sim[transfer_sim$srcchain %in% evm_chains & transfer_sim$destchain %in% evm_chains, "srcaddress"]

# Transform for VisNetwork

nodes <- unique(sort(c(transfer_sim$srcchain, transfer_sim$destchain)))
nodes <- data.frame(
  id = 1:length(nodes),
  label = nodes
)

edges <- transfer_sim
edges <- merge(edges, nodes, by.x = 'srcchain', by.y = "label", all.x = TRUE)
edges$from <- edges$id
edges$id <- NULL
edges <- merge(edges, nodes, by.x = 'destchain', by.y = "label", all.x = TRUE)
edges$to <- edges$id
edges$id <- NULL

# Reference Table for Filtering
# Note this problem is a neighborhood N-degree problem.
# AliceEVM -> Osmo1Alice
# Juno1Alice -> Osmo1Alice
# AxlAlice -> AliceEVM
# You would need 3 joins to get AliceEVM = Osmo1Alice = Juno1Alice = AxlAlice
# If you add: AliceEVM -> Osmo2Alice and Osmo2Alice-> Juno1Alice
# it grows exponentially!


ref <- unique(transfer_sim[, c("srcaddress", "destaddress")])
example_address <- 'osmo1TMIMIELFOZESIIKAXWLJ'


find_3degrees <- function(ref, example_address){
degree1 <- ref[ref$srcaddress == example_address | ref$destaddress == example_address, ]
degree1addresses <- unique(unlist(degree1))
degree2 <- ref[ref$srcaddress %in% degree1addresses | ref$destaddress %in% degree1addresses, ]
degree2addresses <- unique(unlist(degree2))
degree3 <- ref[ref$srcaddress %in% degree2addresses | ref$destaddress %in% degree2addresses, ]
return(degree3)
  }

# 40 1st degree edges
nrow(ref[ref$srcaddress == example_address | ref$destaddress == example_address, ])
# 5,326 3rd degree edges
nrow(find_3degrees(ref, example_address))

