# IcySwap Contract

## Contracts

- ICYSwap
  [0x270E4c4a3952E6d231Db85Db1930BD95b4fc50e8](https://polygonscan.com/address/0x270E4c4a3952E6d231Db85Db1930BD95b4fc50e8#readContract)

## How to run project

1. Install deps with `yarn`
2. To run unit test, use command `npx hardhat test`
3. Fill in .env file (ref from .env.example)
4. Deploy contracts with `npx hardhat run scripts/deploy.ts`

## Note

- Still in experiment. DYOR!

## Todo list

### Feature

- [x] Swap ICY <-> USDC
- [x] TopUpUSDC
- [x] SetConversionRate
- [x] Ownable
- [x] Pausable

### Test

- [x] Swap
- [x] TopUpUSDC
- [x] SetConversionRate
