import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

module.exports = async function (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const {ethers} = hre;
  const address = taskArgs.address;
  const duration = taskArgs.duration;

  const IcyStake = await ethers.getContractFactory("IcyStake");
  const icyStake = IcyStake.attach(address);

  let tx = await (
      await icyStake.setRewardsDuration(duration)
  ).wait()

  console.log(`send tx: ${tx.transactionHash}`)
}

