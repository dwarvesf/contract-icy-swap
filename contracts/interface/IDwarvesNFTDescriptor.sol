// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IDwarvesNFT.sol";

interface IDwarvesNFTDescriptor {
  function tokenURI(IDwarvesNFT nft, uint256 tokenId) external view returns (string memory);
}
