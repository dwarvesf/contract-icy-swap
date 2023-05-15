import { task } from "hardhat/config";

task("deployERC20Mock", "Deploy the ERC20 token mock for testing", require("./deployERC20Mock"))
    .addOptionalParam("name", "The token name (default MyToken)")
    .addOptionalParam("symbol", "The token symbol (default MT)")
    .addOptionalParam("initialSupply", "The initialSupply (default 1000000000000000000000)")

task("notifyRewards", "Notify the rewards amount", require("./notifyRewards"))
    .addParam("address", "The staking contract address")
    .addParam("amount", "The rewards amount")

task("setRewardsDuration", "Set the rewards duration", require("./setRewardsDuration"))
    .addParam("address", "The staking contract address")
    .addParam("duration", "The rewards duration")
