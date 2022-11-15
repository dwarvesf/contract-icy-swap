// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract IcySwap is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable usdc;
    IERC20 public immutable icy;

    // This conversion is follow usdc decimals: 10**6
    // Let say we want 1 icy equal 2 usdc -> conversion rate should be 2 * 10**6
    uint256 public icyToUsdcCoversionRate;

    event Swap(IERC20 indexed fromToken, uint256 indexed fromAmount);
    event TopUpUSDC(uint256 indexed amount);
    event ConversionRateChanged(uint256 conversionRate);

    constructor(
        IERC20 _usdc,
        IERC20 _icy,
        uint256 _conversionRate
    ) {
        usdc = _usdc;
        icy = _icy;
        icyToUsdcCoversionRate = _conversionRate;
    }

    modifier shouldBeValidToken(IERC20 _token) {
        require(_token == usdc || _token == icy, "not allow token");
        _;
    }

    // Swap methods
    function swap(IERC20 _fromToken, uint256 _fromAmount)
        public
        shouldBeValidToken(_fromToken)
        nonReentrant
        whenNotPaused
    {
        if (_fromToken == icy) {
            uint256 toAmount = (_fromAmount * icyToUsdcCoversionRate) /
                (10**18);
            _swap(_fromToken, _fromAmount, usdc, toAmount);
        } else {
            uint256 toAmount = (_fromAmount * (10**18)) /
                icyToUsdcCoversionRate;
            _swap(_fromToken, _fromAmount, icy, toAmount);
        }
        emit Swap(_fromToken, _fromAmount);
    }

    // Moderate methods
    function topUpUSDC(uint256 _amount) public onlyOwner {
        usdc.safeTransferFrom(msg.sender, address(this), _amount);
        emit TopUpUSDC(_amount);
    }

    function setConversionRate(uint256 _conversionRate) public onlyOwner {
        icyToUsdcCoversionRate = _conversionRate;
        emit ConversionRateChanged(_conversionRate);
    }

    // Internal methods
    function _swap(
        IERC20 _fromToken,
        uint256 _fromAmount,
        IERC20 _toToken,
        uint256 _toAmount
    ) internal {
        require(_toToken.balanceOf(address(this)) >= _toAmount, "out of money");
        _fromToken.safeTransferFrom(msg.sender, address(this), _fromAmount);
        _toToken.safeTransfer(msg.sender, _toAmount);
    }
}
