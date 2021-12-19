// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICrowdsaleLock {
  function lockedToken() external view returns (IERC20);

  function start() external view returns (uint256);

  function duration() external view returns (uint256);

  function end() external view returns (uint256);

  function lockedBalance(address beneficiary) external view returns (uint256);

  function transferAndLock(address beneficiary, uint256 amount) external;

  function withdraw() external;
}
