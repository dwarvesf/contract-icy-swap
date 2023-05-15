// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interface/IDwarvesPOCDescriptor.sol";
import "./Lib/CommonType.sol";

contract DPOCDescriptor is IDwarvesPOCDescriptor  {

  function tokenURI(IDwarvesPOC dpoc, uint256 tokenId) external view returns (string memory) {
    CommonType.ContributeInfo memory info = dpoc.getContributionInfo(tokenId);

    string memory image = string.concat(
        "<svg width='290' height='500' viewBox='0 0 290 500' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>",
        renderBackground(),
        renderOuterBorder(),
        renderBorderText(info.owner),
        renderTitle(info.name),
        renderInnerBorder(),
        renderID(tokenId),
        renderMaxStake(info.maxStake),
        renderLogo(),
        "</svg>"
    );
    
    string memory name = string.concat("Dwarves POC #", "Top 1 Brainery");
    string memory description = "Dwarves Proof of contribution NFT collection";

    string memory json = string.concat(
            '{"name":"',
            name,
            '",',
            '"description":"',
            description,
            '",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(image)),
            '"}'
        );

        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(bytes(json))
            );

  }

  function renderBackground() internal pure returns (string memory background) {
    background = '<defs> <filter id="f1"> <feImage result="p0" xlink:href="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nMjkwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI5MCA1MDAnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PHJlY3Qgd2lkdGg9JzI5MHB4JyBoZWlnaHQ9JzUwMHB4JyBmaWxsPScjZTEzZjVlJy8+PC9zdmc+" /> <feImage result="p1" xlink:href="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0nMjkwJyBoZWlnaHQ9JzUwMCcgdmlld0JveD0nMCAwIDI5MCA1MDAnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zyc+PGNpcmNsZSBjeD0nMTcnIGN5PScyNzYnIHI9JzEyMHB4JyBmaWxsPScjYzAyYWFhJy8+PC9zdmc+" /> <feBlend mode="overlay" in="p0" in2="p1" /> <feBlend mode="exclusion" in2="p2" /> <feBlend mode="overlay" in2="p3" result="blendOut" /> <feGaussianBlur in="blendOut" stdDeviation="42" /> </filter> <clipPath id="corners"> <rect width="290" height="500" rx="42" ry="42" /> </clipPath> <path id="text-path-a" d="M40 12 H250 A28 28 0 0 1 278 40 V460 A28 28 0 0 1 250 488 H40 A28 28 0 0 1 12 460 V40 A28 28 0 0 1 40 12 z" /> <path id="minimap" d="M234 444C234 457.949 242.21 463 253 463" /> <filter id="top-region-blur"> <feGaussianBlur in="SourceGraphic" stdDeviation="24" /> </filter> <linearGradient id="grad-up" x1="1" x2="0" y1="1" y2="0"> <stop offset="0.0" stop-color="white" stop-opacity="1" /> <stop offset=".9" stop-color="white" stop-opacity="0" /> </linearGradient> <linearGradient id="grad-down" x1="0" x2="1" y1="0" y2="1"> <stop offset="0.0" stop-color="white" stop-opacity="1" /> <stop offset="0.9" stop-color="white" stop-opacity="0" /> </linearGradient> <mask id="fade-up" maskContentUnits="objectBoundingBox"> <rect width="1" height="1" fill="url(#grad-up)" /> </mask> <mask id="fade-down" maskContentUnits="objectBoundingBox"> <rect width="1" height="1" fill="url(#grad-down)" /> </mask> <mask id="none" maskContentUnits="objectBoundingBox"> <rect width="1" height="1" fill="white" /> </mask> <linearGradient id="grad-symbol"> <stop offset="0.7" stop-color="white" stop-opacity="1" /> <stop offset=".95" stop-color="white" stop-opacity="0" /> </linearGradient> <mask id="fade-symbol" maskContentUnits="userSpaceOnUse"> <rect width="290px" height="200px" fill="url(#grad-symbol)" /> </mask> </defs>';
  }

  function renderOuterBorder() internal pure returns (string memory border) {
    border = '<g clip-path="url(#corners)"> <rect fill="1f9840" x="0px" y="0px" width="500px" height="500px" /> <rect style="filter:url(#f1)" x="0px" y="0px" width="290px" height="500px" /> <g style="filter:url(#top-region-blur);transform:scale(1.5);transform-origin:center top"> <rect fill="none" x="0px" y="0px" width="290px" height="500px" /> <ellipse cx="50%" cy="0px" rx="180px" ry="120px" fill="#000" opacity="0.85" /> </g> <rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)" /> </g>';
  }

  function renderBorderText(address owner) internal pure returns (string memory text) {
    text = string.concat(
      '<text text-rendering="optimizeSpeed">',
      renderTextPath("-100%", owner),
      renderTextPath("0%", owner),
      renderTextPath("50%", owner),
      renderTextPath("-50%", owner),
      '</text>'
    );
  }

  function renderTitle(string memory title) internal pure returns (string memory text) {
    text = string.concat(
    '<g mask="url(#fade-symbol)">',
    '<rect fill="none" x="0px" y="0px" width="290px" height="200px" />',
    '<text y="70px" x="32px" fill="white" font-family="Courier New, monospace" font-weight="200" font-size="28px">POC</text>',
    '<text y="95px" x="32px" fill="white" font-family="Courier New, monospace" font-weight="200" font-size="16px">',
    title,
    '</text>'
    '</g>'
    );
  }

  function renderInnerBorder() internal pure returns (string memory border) {
    border = '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)" />';
  }

  function renderID(uint256 id) internal pure returns (string memory label) {
    label = string.concat(
      '<g style="transform:translate(29px,414px)">',
      '<rect width="140px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)" />',
      '<text x="12px" y="17px" font-family="Courier New, monospace" font-size="12px" fill="white">',
      '<tspan fill="rgba(255,255,255,0.6)">ID:</tspan>',
      Strings.toString(id),
      '</text>',
      '</g>'
    );
  }

  function renderMaxStake(uint256 maxStake) internal pure returns (string memory label) {
    label = string.concat(
      '<g style="transform:translate(29px,444px)">',
      '<rect width="140px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)" />',
      '<text x="12px" y="17px" font-family="Courier New, monospace" font-size="12px" fill="white">',
      '<tspan fill="rgba(255,255,255,0.6)">Max stake:</tspan>',
      Strings.toString(maxStake),
      '</text>'
      '</g>'
    );
  }

  function renderLogo() internal pure returns (string memory logo) {
    logo = '<g style="transform:translate(226px,433px)"> <path d="M5.208 40.726c-2.804 0-5.074-2.279-5.074-5.093V5.093C.134 2.278 2.404 0 5.208 0l12.703.015c11.292 0 20.433 9.262 20.285 20.623-.149 11.183-9.438 20.088-20.582 20.088H5.208z" fill="#E13F5E"></path> <path d="M7.76 31.821h-.652a.634.634 0 0 1-.638-.64v-5.108c0-.357.282-.64.638-.64h5.09c.356 0 .638.283.638.64v.655c0 2.815-2.27 5.093-5.075 5.093zM7.108 16.528H22.97c2.804 0 5.075-2.278 5.075-5.092v-.61a.666.666 0 0 0-.668-.67H11.56c-2.805 0-5.075 2.278-5.075 5.092v.64c0 .358.282.64.623.64zM7.108 24.167h8.25c2.805 0 5.075-2.278 5.075-5.092v-.64a.634.634 0 0 0-.638-.64H7.108a.634.634 0 0 0-.638.64v5.092c.015.357.297.64.638.64z" fill="#FFF"></path> </g>';
  }

  function renderTextPath(string memory startOffset, address owner) internal pure returns (string memory text) {
    text = string.concat(
      '<textPath startOffset="', 
      startOffset,
      '" fill="white" font-family="Courier New, monospace" font-size="10px" xlink:href="#text-path-a">',
      Strings.toHexString(uint160(owner), 20),
      unicode" • ",
      "POC",
      '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
      '</textPath>'
    );
  }

}