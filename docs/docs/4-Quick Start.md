# Quick Start

## Smart Contracts
1. Start local Ethereum node
```shell
cd contracts; anvil
```

2. Deploy Leasy contract to local Ethereum node
```shell
forge create src/Leasy.sol:Leasy --private-key <private_key_from_anvil_output> --constructor-args <erc-721-token-name> <erc-721-token-symbol>
```

3. Copy address of deployed contract to clipboard

4. Build
```shell
$ forge build
```

5. Navigate to Remix IDE

6. Click on `Deploy & run transactions`, select `Dev - Foundry Provider`, enter contract address from output of step 3.
   in `At Address` field and interact with contract

## Frontend
1. Start Frontend
```shell
cd frontend; npm i; npm run dev
```

2. Create `.env.local` file with properties:
```
NEXT_PUBLIC_ALCHEMY_ID=<your alchemy ID>
NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS=<address of contract from step 3.>
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=<your wallet connect project ID>
```

2. Navigate to http://localhost:3000
