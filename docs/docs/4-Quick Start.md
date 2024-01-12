# Quick Start

## Smart Contracts

1. Start local Ethereum node

```shell
cd contracts; anvil
```

2. a. Deploy `LeasyStay` contract to local Ethereum node and save the address after `Deployed to: `

```shell
forge create src/LeasyStay.sol:LeasyStay --private-key <private_key_from_anvil_output> --constructor-args LEASY_STAY_LOCAL_1_NAME LEASY_STAY_LOCAL_1_SYMBOL
```

2. b. Deploy `Leasy` contract to local Ethereum node and save the address after `Deployed to: `

```shell
forge create src/Leasy.sol:Leasy --private-key <private_key_from_anvil_output> --constructor-args LEASY_LOCAL_1_NAME LEASY_LOCAL_1_SYMBOL <leasy stay contract address from 2. a.>
```

3. Build

```shell
$ forge build
```

4. Navigate to Remix IDE

5. Create project and add `Leasy.sol` and `LeasyStay.sol` under `contracts`, compile them

6. Click on `Deploy & run transactions`, select `Dev - Foundry Provider`,

7. Select `LeasyStay` from the `CONTRACT` dropdown, enter the address from 2. a. in `At Address` field and click on `At Address`

8. Select `Leasy` from the `CONTRACT` dropdown, enter the address from 2. b. in `At Address` field and click on `At Address`

At this point, you may now interact with the contracts in Remix IDE.

## Frontend

1. Start Frontend

```shell
cd frontend; npm i; npm run dev
```

2. Create `.env.local` file with properties:

```
NEXT_PUBLIC_ALCHEMY_ID=<your alchemy ID>
NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS=<address of contract from step 2. b.>
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=<your wallet connect project ID>
```

2. Navigate to http://localhost:3000

At this point, you may now interact with the dApp which makes calls to the deployed `Leasy` and `LeasyStay` smart
contracts.
