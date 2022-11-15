// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IcyMock is ERC20 {
    constructor(uint256 initialSupply) ERC20("Icy", "ICY") {
        _mint(msg.sender, initialSupply);
    }
}
