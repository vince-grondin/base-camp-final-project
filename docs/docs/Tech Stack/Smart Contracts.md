# Smart Contracts
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
