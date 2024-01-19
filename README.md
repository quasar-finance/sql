# SQL Query Repository

## Overview

This repository contains a collection of SQL queries organized into different categories. Each query is designed to
perform specific operations and retrieve data for various purposes, particularly in the context of decentralized asset
management smart contract vaults.

## Structure

The repository is organized into the following directories, each containing related SQL queries:

- `aidrop`: Queries related to airdrop operations on the Quasar chain.
- `lp`: Queries for Liquidity Pool (LP) Strategy operations on the Quasar chain.
- `cl`: Queries pertaining to Concentrated Liquidity (CL) Strategy operations on the Osmosis chain.

## Usage

To use these queries, simply navigate to the respective directory and choose the query that fits your requirement.
Ensure you have the necessary database permissions and understand the impact of each query before execution. All queries
are using the Numia dataset, which is publicly accessible. For more information,
visit [Numia's Documentation](https://docs.numia.xyz/overview/sql-access/querying-numia-datasets).

## Queries

### Airdrop Queries

- `quasar_aridrop_1.sql`: Query to perform specific airdrop operations on the Quasar chain.
- `quasar_aridrop_2.sql`: Query to handle advanced airdrop scenarios on the Quasar chain.

### Liquidity Pool (LP) Queries

- `lp_unbond.sql`: Query for handling unbonding operations in the LP strategy.
- `lp_unbond_response.sql`: Query to retrieve responses for LP unbonding operations.
- `lp_bond_manual_mint.sql`: Manages manual minting in bond operations for LP.
- `lp_withdraw_response_not_reliable.sql`: Retrieves responses for LP withdrawals, noting reliability issues.
- `lp_bond_response.sql`: Query to retrieve responses for bond operations in LP.
- `lp_rewards.sql`: Calculates rewards for LP strategy operations.
- `lp_bond.sql`: Handles bond operations within the LP strategy.
- `lp_rewards_actual.sql`: Computes actual rewards based on LP strategy operations.
- `lp_rewards_fixed.sql`: Calculates fixed rewards for LP strategy.
- `lp_withdraw.sql`: Manages withdrawal operations from the LP vault.

### Concentrated Liquidity (CL) Queries

- `cl_rewards.sql`: Query to calculate user yields in the CL strategy.
- `cl_deposit.sql`: Query for user deposits into the CL vault.
- `cl_claim.sql`: Query to handle claim operations in the CL strategy.
- `cl_withdraw.sql`: Query for user withdrawals from the CL vault.

## Contributing

Feel free to contribute to this repository by adding new queries or improving existing ones. Please ensure you follow
the SQL formatting guidelines and provide a clear description of your changes.
