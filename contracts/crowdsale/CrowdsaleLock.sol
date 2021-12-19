// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICrowdsaleLock.sol";

contract CrowdsaleLock is ICrowdsaleLock, Ownable {
  using SafeERC20 for IERC20;

  IERC20 private _lockedToken;

  uint256 private immutable _start;
  uint256 private immutable _duration;

  mapping(address => uint256) private _lockedBalances;

  constructor(IERC20 lockedToken_, uint256 duration_) {
    require(
      address(lockedToken_) != address(0),
      "Crowdsale: lockedToken cannot be zero address"
    );

    _lockedToken = lockedToken_;
    _duration = duration_;
    _start = block.timestamp;
  }

  function lockedToken() public view returns (IERC20) {
    return _lockedToken;
  }

  function start() public view returns (uint256) {
    return _start;
  }

  function duration() public view returns (uint256) {
    return _duration;
  }

  function end() public view returns (uint256) {
    return _start + _duration;
  }

  function lockedBalance(address beneficiary) public view returns (uint256) {
    return _lockedBalances[beneficiary];
  }

  // TODO: double check function
  function transferAndLock(address beneficiary, uint256 amount) external {
    require(
      beneficiary != address(0),
      "CrowdsaleLock: beneficiary cannot be zero address"
    );
    require(amount > 0, "CrowdsaleLock: amount is 0");

    _lockedToken.safeTransferFrom(msg.sender, address(this), amount);

    _lockedBalances[beneficiary] += amount;
  }

  function withdraw() external {
    require(
      _lockedBalances[msg.sender] > 0,
      "CrowdsaleLock: msg.sender is not a beneficiary"
    );
    require(block.timestamp >= end(), "Crowdsale: too eraly for withdraw");

    uint256 amount = _lockedBalances[msg.sender];
    _lockedBalances[msg.sender] = 0;

    _lockedToken.safeTransfer(msg.sender, amount);
  }
}
