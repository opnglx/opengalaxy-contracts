// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrowdsaleLock is Ownable {
  using SafeERC20 for IERC20;

  mapping(address => uint256) private _beneficiaries;
}
