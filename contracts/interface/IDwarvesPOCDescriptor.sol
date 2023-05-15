// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IDwarvesPOC.sol";

interface IDwarvesPOCDescriptor {
  function tokenURI(IDwarvesPOC nft, uint256 tokenId) external view returns (string memory);
}
