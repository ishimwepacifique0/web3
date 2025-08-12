## RandaCore Hardhat Project

This repo contains Solidity smart contracts and a Hardhat setup to compile, test, deploy, and interact with them. The main example contract here is `RandaCore`, alongside a sample `Lock` contract and an Ignition module.

### Prerequisites

- Node.js and npm installed
- An EVM account private key with test funds if deploying to a public test network

### Install

```bash
npm install
```

### Environment variables

Create a `.env` file in the project root with:

```bash
PRIVATE_KEY=690550467fb91ea44c935848e8139d7b78980d94782e25316da592fe7e5cdf22
RANDA_CONTRACT_ADDRESS=0xB2075667e23B40006998538626702a6150fBDdBe
```

Network `coretestnet` is preconfigured in `hardhat.config.js` and reads `PRIVATE_KEY` from `.env`.

### Compile

```bash
npx hardhat compile
```

### Test (runs sample tests for `Lock`)

```bash
npx hardhat test
```

### Run a local node (optional)

```bash
npx hardhat node
```

### Deploy `RandaCore`

- Localhost (ensure the local node is running):

```bash
npx hardhat run scripts/deploy.js --network localhost
```

 output:

```text
[dotenv@17.2.1] injecting env (2) from .env -- tip: ⚙️  suppress all logs with { quiet: true }
[dotenv@17.2.1] injecting env (0) from .env -- tip: 🔐 prevent committing .env to code: https://dotenvx.com/precommit
Contract deployed to: 0x0DE3e02b2bC0f9d2121B6a8063Fef4480eE03f38
```

- Core Testnet (requires `PRIVATE_KEY` with test funds):

```bash
npx hardhat run scripts/deploy.js --network coretestnet
```

After deployment, copy the printed contract address and set `RANDA_CONTRACT_ADDRESS` in `.env`.

### Interact with `RandaCore`

Ensure `RANDA_CONTRACT_ADDRESS` is set in `.env` to the deployed address, then:

```bash
npx hardhat run scripts/interact.js --network coretestnet
```

For local node usage, switch the network:

```bash
npx hardhat run scripts/interact.js --network localhost
```

### Screenshots

![RandaCore Screenshot](./Screenshot%202025-08-12%20at%2003.02.38.png)

![RandaCore Screenshot 2](./Screenshot%202025-08-12%20at%2003.13.16.png)

![RandaCore Screenshot 3](./Screenshot%202025-08-12%20at%2003.16.28.png)
