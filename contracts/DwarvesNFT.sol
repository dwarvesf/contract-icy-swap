// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interface/IDwarvesNFTDescriptor.sol";
import "./interface/IDwarvesNFT.sol";
import "./Lib/CommonType.sol";

contract DwarvesNFT is ERC721, AccessControl, IDwarvesNFT {
  using Counters for Counters.Counter;

  // Access Control roles
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  // Third party contracts
  IDwarvesNFTDescriptor public descriptor;

  // NFT state
  Counters.Counter private _tokenIdCounter;
  uint256 public maxSupply = 9999;
  bool public minting = false;

  mapping(uint256 => CommonType.ContributeInfo) public info;

  constructor(IDwarvesNFTDescriptor _descriptor) ERC721("Dwarves NFT", "DNFT") {
    descriptor = _descriptor;
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
  }

  function mint(CommonType.ContributeInfo calldata params) external onlyRole(MINTER_ROLE) {
    require(minting, "Minting needs to be enabled to start minting");
    require(_tokenIdCounter.current() < maxSupply, "Exceed max supply");
    _tokenIdCounter.increment();
    uint256 countId = _tokenIdCounter.current();
    uint256 tokenId = (1000000000 * params.contributeType) + (100000000 * params.expiry) + (10000 * params.issued) + countId;
    _mint(params.owner, tokenId);
    info[tokenId] = params;
  }

  function setMinting(bool value) external onlyRole(DEFAULT_ADMIN_ROLE) {
      minting = value;
  }

  function setDescriptor(IDwarvesNFTDescriptor newDescriptor) external onlyRole(DEFAULT_ADMIN_ROLE) {
      descriptor = newDescriptor;
  }

  function withdraw() external payable onlyRole(DEFAULT_ADMIN_ROLE) {
      (bool os,)= payable(msg.sender).call{value: address(this).balance}("");
      require(os);
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
      require(_exists(tokenId), "not exist.");
      return descriptor.tokenURI(this, tokenId);
  }

  function getContributionInfo(uint256 tokenId) external view returns (CommonType.ContributeInfo memory) {
    return info[tokenId];
  }

  function _beforeTokenTransfer(
      address from,
      address to,
      uint256 tokenId, 
      uint256 batchSize
  ) internal virtual override {
    require(from == address(0) || to == address(0), "Nonstranferable");
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  // The following functions are overrides required by Solidity.

  function supportsInterface(bytes4 interfaceId)
      public
      view
      override(ERC721, AccessControl)
      returns (bool)
  {
      return super.supportsInterface(interfaceId);
  }
}
