import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";

module.exports = async function (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) {
  const ERC20Mock = await hre.ethers.getContractFactory("ERC20Mock");
  const name = taskArgs.name ?? "MyToken";
  const symbol = taskArgs.symbol ?? "MT";
  const inititalSupply = taskArgs.inititalSupply ?? "1000000000000000000000";
  const erc20Mock = await ERC20Mock.deploy(name, symbol, inititalSupply);
  await erc20Mock.deployed()
  console.log(`new erc20 mock deployed at ${erc20Mock.address}`);

  console.log("verifying contract...")
  await hre
    .run("verify:verify", {
      address: erc20Mock.address,
      constructorArguments: [name, symbol, inititalSupply],
    })
    .then(() => {
      console.log(`contract verified success`);
    })
    .catch((e) => {
      console.log(`contract verify failed ${e}`);
    });
}
