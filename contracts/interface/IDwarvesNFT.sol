// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Lib/CommonType.sol";

interface IDwarvesNFT {
  function getContributionInfo(uint256 tokenId) external view returns (CommonType.ContributeInfo memory);
}
