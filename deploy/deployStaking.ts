import hre, {ethers} from "hardhat";

async function main() {
  console.log("deploying staking contract...");
  // address of staking token ($icy)
  const stakingToken = "0xeB5CD31F7e1667832C4cD46a348a724ED10AE296";
  // address of reward token ($dfg)
  const rewardToken = "0xd327B6D878bCD9D5EC6a5BC99445985d75F0D6E5";
  
  const IcyStake = await ethers.getContractFactory("IcyStake");
  const icyStake = await IcyStake.deploy(stakingToken, rewardToken);
  await icyStake.deployed();

  console.log(`IcyStake deployed to ${icyStake.address}`);

  console.log("verifying contract...");
  await hre
    .run("verify:verify", {
    address: icyStake.address,
    constructorArguments: [stakingToken, rewardToken],
  })
  .then(() => {
    console.log("contract veified success");
  })
  .catch((e) => {
    console.log(`contract verify failed ${e}`);
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
