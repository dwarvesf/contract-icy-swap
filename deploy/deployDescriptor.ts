import hre, { ethers } from "hardhat";

async function main() {
  console.log(`deploying contract...`);
  const Descriptor = await ethers.getContractFactory("DNFTDescriptor");
  const descriptor = await Descriptor.deploy();
  await descriptor.deployed();
  console.log(`deployed descriptor to ${descriptor.address}`);

  console.log(`verifying descriptor contract...`);
  await hre
    .run("verify:verify", {
      address: descriptor.address,
      constructorArguments: [],
    })
    .then(() => {
      console.log(`contract verified success`);
    })
    .catch((e) => {
      console.log(`contract verify failed ${e}`);
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
