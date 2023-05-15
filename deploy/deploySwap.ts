import hre, { ethers } from "hardhat";

async function main() {
  console.log(`deploying contract...`);
  const usdc = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
  const icy = "0x8D57d71B02d71e1e449a0E459DE40473Eb8f4a90";
  const icyToUsdcConversionRate = ethers.utils.parseUnits("1.5", 6); // 1 icy = 1.5 usdc, decimal = 6
  const IcySwap = await ethers.getContractFactory("IcySwap");
  const icySwap = await IcySwap.deploy(usdc, icy, icyToUsdcConversionRate);
  await icySwap.deployed();

  console.log(`IcySwap deployed to ${icySwap.address}`);

  console.log(`verifying contract...`);
  await hre
    .run("verify:verify", {
      address: icySwap.address,
      constructorArguments: [usdc, icy, icyToUsdcConversionRate],
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
