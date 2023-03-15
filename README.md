# Topic: Axelar EVM User Research

Axelar EVM (Squid/GMP) focused study for market fit & growth opportunity

Axelar is a cross-chain communication protocol that connects IBC and EVM chains to not only move 
tokens like USDC, ETH, AVAX, etc. across chains, but also pass messages via its General Message Passing (GMP) 
system.

This repo holds all the code behind our EVM Squid Router study, where we looked at early power users 
of Squid Router (which uses Axelar GMP) to move tokens (specifically USDC & axlUSDC) across EVM chains: ETH, Polygon, BSC, Avalanche, and Arbitrum, and identify 310,000+ EVM Addresses that fit the profile of a potential power user. This Target Addressable Market supports growth planning for Axelar in the EVM ecosystem.

For a deeper dive into the context, 
you can check out the report on our [research site](https://science.flipsidecrypto.xyz/research/) at [axelar_evm_tam](https://science.flipsidecrypto.xyz/axelar_evm_tam/).

If you aren't interested in code and want the shortest summary of the situation, you can check out the
email sized [axl-squid-evm-study](https://flipsidecrypto.beehiiv.com/p/axl-squid-evm-study) on our research beehiiv and subscribe to get (summaries of) the best crypto research direct to your inbox.

# Reproduce Analysis

All analysis is reproducible using the R programming language. You'll need (1) an shroomDK 
API key to copy our SQL queries and extract data from the [FlipsideCrypto data app](https://next.flipsidecrypto.xyz/); and (2) renv to get the exact package versions we used. 

## shroomDK

shroomDK is an R package that accesses the FlipsideCrypto REST API; it is also available for Python.
You pass SQL code as a string to our API and get up to 1M rows of data back!

Check out the [documentation](https://docs.flipsidecrypto.com/shroomdk-sdk/get-started) and get your free API Key today.

## renv 

renv is a package manager for the R programming language. It ensures analysis is fully reproducible by tracking the exact package versions used in the analysis.

`install.packages('renv')`

## Instructions 

To replicate this analysis please do the following:

1. Clone this repo.
2. Save your API key into a .txt file as 'api_key.txt' (this exact naming allows the provided .gitignore to ignore your key and keep it off github).
3. Open the Axelar-Research R Project file in your R IDE (we recommend, RStudio).
4. Confirm you have renv installed. 
5. Restore the R environment using `renv::restore()` while in the Axelar-Research R Project.
6. You can now run axelar_evm_study.Rmd. 

If any errors arise, double check you have saved your API key in the expected file name and format.

