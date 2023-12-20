# Base Camp - Roch's Final Project - "Leasy"
## Summary
The final step of the [Base Bootcamp](https://base.org/bootcamp) is to design and build a project.
The high-level requirements are
- Include at least 1 of the following 3 choices: ERC-20 Token, ERC-721 Token, ERC-1155 Token
Import and Use 1 to 3: Audited third-party smart contracts by OpenZeppelin, Thirdweb, or other similar, such as OpenZeppelin’s EnumerableSet, or Ownable
- Utilize 1 of the following 3 choices: The `payable` keyword, Contract-to-contract interactions, The `new` keyword/contract factory

## Tech Stack
### Frontend
This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

This project uses [`next/font`](https://nextjs.org/docs/basic-features/font-optimization) to automatically optimize and load Inter, a custom Google Font.

#### Running locally
1. First, run the development server:

```bash
npm run dev
```

2. Open [http://localhost:3000](http://localhost:3000) with your browser.

### Contracts
This codebase uses Foundry, a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.

Foundry consists of:
- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

#### Running locally
1. Start local Ethereum node
```shell
anvil
```

2. Deploy Leasy contract to local Ethereum node
```shell
forge create src/Leasy.sol:Leasy --private-key <private_key_from_anvil_output> --constructor-args <erc-721-token-name> <erc-721-token-symbol>
```

#### Foundry Popular Commands
##### Build
```shell
$ forge build
```

##### Test
```shell
$ forge test
```

##### Format
```shell
$ forge fmt
```

##### Gas Snapshots
```shell
$ forge snapshot
```

##### Anvil
```shell
$ anvil
```

##### Deploy
```shell
$ forge script script/<contract_name>.s.sol:<contract_script_name> --rpc-url <your_rpc_url> --private-key <your_private_key>
```

##### Cast
```shell
$ cast <subcommand>
```

##### Help
```shell
$ forge --help
$ anvil --help
$ cast --help
```
