import hre, { ethers } from "hardhat";

async function main() {
  console.log(`deploying contract...`);
  const Descriptor = await ethers.getContractFactory("DPOCDescriptor");
  const descriptor = await Descriptor.deploy();
  await descriptor.deployed();
  console.log(`deployed descriptor to ${descriptor.address}`);

  const DPOC = await ethers.getContractFactory("DwarvesPOC");
  const dpoc = await DPOC.deploy(descriptor.address);
  await dpoc.deployed();

  console.log(`deployed DPOC to ${dpoc.address}`);

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

  console.log(`verifying dpoc contract...`);
  await hre
    .run("verify:verify", {
      address: dpoc.address,
      constructorArguments: [descriptor.address],
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
