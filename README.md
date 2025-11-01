# FlowReel — Decentralized Movie Streaming on Flow Blockchain

FlowReel is a decentralized movie streaming platform where creators can mint their films as NFTs, and fans can buy or rent movies directly — all powered by the Flow blockchain.

Creators earn transparently through on-chain payments, DAO-managed rewards, and AI-driven content moderation — ensuring fair, censorship-free access for everyone.

## Features

### For Viewers

- **Buy or Rent Movies** — Own your favorite films as NFTs or rent them for limited time access.
- **Seamless Payments** — Powered by FungibleToken and FlowToken contracts on Flow Testnet.
- **Automatic NFT Revocation** — Rented NFTs are revoked automatically after the rental period using Flow's scheduled transactions.

### For Creators

- **Mint Your Films as NFTs** — Full ownership and on-chain revenue tracking.
- **DAO Verification** — A DAO validates creators and manages platform governance transparently.
- **Instant Revenue Sharing** — Payouts are automatically distributed through flow payout modules.
- **Creator Loans** — DAO treasury can issue loans to verified creators for production support.

### AI Agents

- **Content Moderation** — AI agents analyze uploaded movies to detect guideline violations or adult content before minting.
- **Fair Curation** — AI helps surface diverse creators and prevent centralized bias.

## Tech Stack

| Layer | Tools / Frameworks |
|-------|-------------------|
| Blockchain | Flow Blockchain |
| Smart Contracts | Cadence (FungibleToken, FlowToken, NFT Contract, DAO Contract) |
| Frontend | React |
| Blockchain Integration | @onflow/react-sdk |
| AI Module | Integrated moderation and tagging agent |
| Storage | IPFS + Pinata (for movie and metadata storage) |

## How It Works

1. **Creators upload movies** — The movie is analyzed by an AI agent for content safety.
2. **Mint NFT** — The verified film is minted as an NFT using Flow's NFT standard.
3. **Buy/Rent** — Viewers can buy (permanent) or rent (temporary access) the NFT.
4. **Payments** — FLOW tokens are transferred directly to creators via smart contract.
5. **Scheduled Transactions** — Rented NFTs automatically expire and access is revoked.
6. **DAO Governance** — Handles creator verification, revenue sharing, and community proposals.

## Smart Contracts

**Deployed on Flow Testnet:** `0x21bcdad218e253c9`

### Contracts

- **MovieNFT.cdc** — Defines the movie NFT structure and metadata.
- **MovieMarketplace.cdc** — Handles movie purchase and marketplace logic.
- **MovieRental.cdc** — Manages movie rental functionality and temporary access.

## Frontend Flow

Flow React SDK Integration:

- TransactionButton handles buy/rent transaction execution directly from frontend.
- Wallet connection via Flow Wallet Extension.
- Real-time transaction feedback with success/failure alerts.

## Demo

Currently live on Flow Testnet

- Contracts deployed at: `0x21bcdad218e253c9`
- Frontend connected using Flow Testnet configuration.

## Future Roadmap

- Full DAO voting and governance UI.
- Advanced AI agent fine-tuning for content recommendations.
- Cross-platform royalties and multi-chain support.
