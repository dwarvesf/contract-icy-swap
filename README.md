# IcySwap Contract

## Contracts

- **ICYSwap:**

  [0x8De345A73625237223dEDf8c93dfE79A999C17FB](https://polygonscan.com/address/0xd327B6D878bCD9D5EC6a5BC99445985d75F0D6E5#readContract) (USDT)
  [0xd327B6D878bCD9D5EC6a5BC99445985d75F0D6E5](https://polygonscan.com/address/0xd327B6D878bCD9D5EC6a5BC99445985d75F0D6E5#readContract) (USDC.e)

## How to run project

1. Install deps with `yarn`
2. To run unit test, use command `npx hardhat test`
3. cp .env.example .env and update env configs
4. Deploy contracts with `npx hardhat run deploy/deploySwap.ts`

## Note

- Still in experiment. DYOR!

## Todo list

### Feature

- [x] Swap ICY -> USDC
- [x] SetConversionRate
- [x] WithdrawToOwner
- [x] Ownable
- [x] Pausable
- [ ] Staking ICY

### Test

- [x] Swap
- [x] SetConversionRate
- [x] WithdrawToOwner
