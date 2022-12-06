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
    uint256 public icyToUsdcConversionRate;

    event Swap(IERC20 indexed fromToken, uint256 indexed fromAmount);
    event ConversionRateChanged(uint256 conversionRate);
    event WithdrawToOwner(IERC20 indexed token, uint256 amount);

    constructor(
        IERC20 _usdc,
        IERC20 _icy,
        uint256 _conversionRate
    ) {
        usdc = _usdc;
        icy = _icy;
        icyToUsdcConversionRate = _conversionRate;
    }

    // Swap methods
    function swap(uint256 _amountIn) external nonReentrant whenNotPaused {
        uint256 amountOut = (_amountIn * icyToUsdcConversionRate) / (10**18);
        _swap(icy, _amountIn, usdc, amountOut);
        emit Swap(icy, _amountIn);
    }

    // Moderate methods
    function setConversionRate(uint256 _conversionRate) external onlyOwner {
        icyToUsdcConversionRate = _conversionRate;
        emit ConversionRateChanged(_conversionRate);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdrawToOwner(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        require(balance > 0, "contract has no balance");
        _token.safeTransfer(msg.sender, balance);
        emit WithdrawToOwner(_token, balance);
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
