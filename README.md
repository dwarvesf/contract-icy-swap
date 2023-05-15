# IcySwap Contract

## Contracts

- **ICYSwap:**
  [0xd327B6D878bCD9D5EC6a5BC99445985d75F0D6E5](https://polygonscan.com/address/0xd327B6D878bCD9D5EC6a5BC99445985d75F0D6E5#readContract)

## How to run project

1. Install deps with `yarn`
2. To run unit test, use command `npx hardhat test`
3. Fill in .env file (ref from .env.example)
4. Deploy contracts with `npx hardhat run scripts/deploy.ts`

## Note

- Still in experiment. DYOR!

## Todo list

### Feature

- [x] Swap ICY -> USDC
- [x] SetConversionRate
- [x] WithdrawToOwner
- [x] Ownable
- [x] Pausable
- [] Staking ICY

### Test

- [x] Swap
- [x] SetConversionRate
- [x] WithdrawToOwner
