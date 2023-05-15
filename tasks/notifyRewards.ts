import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

module.exports = async function (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const {ethers} = hre;
  const address = taskArgs.address;
  const amount = taskArgs.amount;

  const IcyStake = await ethers.getContractFactory("IcyStake");
  const icyStake = IcyStake.attach(address);

  let tx = await (
      await icyStake.notifyRewardAmount(amount)
  ).wait()

  console.log(`send tx: ${tx.transactionHash}`)
}

