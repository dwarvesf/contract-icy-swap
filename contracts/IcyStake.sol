// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract IcyStake is Ownable, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  // State
  IERC20 public immutable stakingToken;
  IERC20 public immutable rewardToken;

  // Duration of rewards to be paid out (in seconds)
  uint public duration;
  // Timestamp of when the rewards finish
  uint public finishAt;
  // Minumum of last updated time and reward finish time
  uint public updatedAt;
  // Reward to be paid out per second
  uint public rewardRate;
  // Sum of (reward rate * dt * 1e18 / total supply)
  uint public rewardPerTokenStored;
  // User address => rewardPerTokenStored
  mapping(address => uint) public userRewardPerTokenPaid;
  // User address => rewards to be claimed
  mapping(address => uint) public rewards;

  // Total staked
  uint public totalSupply;
  // User address => staked amount
  mapping (address => uint) public balanceOf;

  // Events
  event Deposit(address indexed user, uint256 indexed amount);
  event Withdraw(address indexed user, uint256 indexed amount);
  event RescueFund(IERC20 indexed token, uint256 indexed amount);

  constructor(
    IERC20 _stakingToken,
    IERC20 _rewardToken
  ) {
    stakingToken = _stakingToken;
    rewardToken = _rewardToken;
  }

  modifier updateReward(address account) {
    rewardPerTokenStored = rewardPerToken();
    updatedAt = lastTimeRewardApplicable();

    if (account != address(0)) {
      rewards[account] = earned(account);
      userRewardPerTokenPaid[account] = rewardPerTokenStored;
    }

    _;
  }

  function lastTimeRewardApplicable() public view returns (uint) {
    return _min(finishAt, block.timestamp);
  }


  function rewardPerToken() public view returns (uint) {
    if (totalSupply == 0) {
      return rewardPerTokenStored;
    }

    return 
        rewardPerTokenStored +
        (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
        totalSupply;
  }

  // Main 
  function deposit(uint256 amount) external whenNotPaused updateReward(msg.sender) {
    require(amount > 0, "amount = 0") ;
    stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
    emit Deposit(msg.sender, amount);
  }

  function withdraw(uint256 amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
    require(amount > 0, "amount = 0");
    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    stakingToken.safeTransfer(msg.sender, amount);
    emit Withdraw(msg.sender, amount);
  }

  function earned(address account) public view returns (uint) {
    return 
        ((balanceOf[account] * 
          (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
        rewards[account]; 
  }

  function getReward() external updateReward(msg.sender) {
    uint reward = rewards[msg.sender];
    if (reward > 0) {
      rewards[msg.sender] = 0;
      rewardToken.safeTransfer(msg.sender, reward);
    }
  }

  // Moderate
  function setRewardsDuration(uint _duration) external onlyOwner {
    require(finishAt < block.timestamp, "reward duration not finished");
    duration = _duration;
  }

  function notifyRewardAmount(uint amount) external onlyOwner updateReward(address(0)) {
    if (block.timestamp >= finishAt) {
      rewardRate = amount / duration;
    } else {
      uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
      rewardRate = (amount + remainingRewards) / duration;
    }

    require(rewardRate > 0, "reward rate = 0");
    require(rewardRate * duration <= rewardToken.balanceOf(address(this)), "reward amount > balance");

    finishAt = block.timestamp + duration;
    updatedAt = block.timestamp;
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  // Rescue the fund when someone send token to the contract
  function rescueFund(IERC20 token) external onlyOwner {
    uint256 balance = token.balanceOf(address(this));
    require(balance > 0, "insuffience balance");
    token.safeTransfer(msg.sender, balance);
    emit RescueFund(token, balance);
  }

  // internal
  function _min(uint x, uint y) private pure returns (uint) {
    return x <= y ? x : y;
  }
}
