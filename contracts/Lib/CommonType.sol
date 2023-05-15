// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library CommonType {
  struct ContributeInfo {
    string name; // top 1 contribute
    uint256 contributeType; // monthly = 1, 6m = 2, anual = 3
    uint256 expiry; // 3, 6, 12 month
    uint256 stakingRate; // 1 dfg, 2 dfg, 3 dfg
    uint256 maxStake; // 1000 icy
    uint256 stakingTimeLeft; // 30 * 24 * 3600 // 1 month
    uint256 issued; // MMYY (2305)
    address owner;
  }
}
