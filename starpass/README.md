
# Starpass NFT Smart Contract

This project implements a fan NFT system called **Starpass**, where fans can mint, trade, and lease NFTs. The contract supports tiered NFTs, royalty payments, and leasing functionality.

## Features

- **Minting NFTs**: Users can mint new NFTs with associated metadata and tier levels.
- **Transferring NFTs**: NFTs can be transferred between users, and the contract automatically handles royalty payments to creators.
- **Leasing NFTs**: NFT owners can lease their NFTs to other users for a specified duration.
- **Royalty Payments**: Creators of NFTs can set a royalty percentage that will be paid whenever the NFT is transferred.
- **Metadata & Tier Information**: Each NFT can have custom metadata and a specific tier value.
- **Ownership & Lease Checking**: Functions are provided to check the current owner or lessee of an NFT.

## Smart Contract Overview

### Minting an NFT

The `mint-nft` function allows a user to mint a new NFT. This function requires:
- **Recipient**: The address that will receive the NFT.
- **Tier**: The tier level for the NFT (must be within a predefined range).
- **Metadata**: A UTF-8 string that contains metadata about the NFT (e.g., image URL, description).
- **Royalty Percentage**: The percentage of royalties the creator will receive on every sale (0-100%).

```clarity
(define-public (mint-nft (recipient principal) (tier uint) (metadata (string-utf8 256)) (royalty-percentage uint))
```

### Transferring an NFT

The `transfer-nft` function enables the owner to transfer their NFT to a new recipient. Royalties are automatically paid to the original creator if applicable.

```clarity
(define-public (transfer-nft (nft-id uint) (recipient principal))
```

### Leasing an NFT

Owners can lease their NFTs using the `lease-nft` function. The lease duration must be greater than zero, and the lessee cannot be the zero address.

```clarity
(define-public (lease-nft (nft-id uint) (lessee principal) (lease-duration uint))
```

### Checking Ownership or Lease

The `get-current-holder` function allows users to check who currently holds the NFT, either the owner or a lessee, depending on the lease status.

```clarity
(define-read-only (get-current-holder (nft-id uint))
```

### Checking Tier and Metadata

You can retrieve the tier and metadata for any NFT using the following read-only functions:

```clarity
(define-read-only (get-tier (nft-id uint))
(define-read-only (get-metadata (nft-id uint))
```

## Contract Data Structures

### Maps

- **nft-tiers**: Maps each NFT ID to a tier value.
- **nft-owners**: Maps each NFT ID to its current owner.
- **nft-metadata**: Stores metadata for each NFT.
- **nft-royalties**: Stores royalty information (creator and percentage) for each NFT.
- **nft-leases**: Stores leasing information (lessee and lease-end) for each NFT.

### Constants and Variables

- **MAX-TIER**: The maximum tier value for an NFT (currently set to 10).
- **total-nfts**: A counter tracking the total number of NFTs minted.


## Requirements

- Clarity language (for smart contract development).
- Clarinet (for testing and deploying contracts).

## Setup and Testing

1. Install **Clarinet** following the instructions from the [Clarinet documentation](https://docs.hiro.so/smart-contracts/clarinet#installation).
2. Clone this repository and navigate to the project directory.
3. Run the contract check for syntax errors:

   ```bash
   clarinet check
   ```

4. Run tests (you can write custom unit tests in the `tests` folder):

   ```bash
   clarinet test
   ```

## Deployment

To deploy the contract, follow the steps below:
1. Write your deployment script in Clarinet.
2. Deploy the contract to the Stacks blockchain using `clarinet deploy` or your preferred method.
