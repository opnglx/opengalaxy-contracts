// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./CrowdsaleV2.sol";
import "./interfaces/ICrowdsaleLock.sol";

contract LockableCrowdsale is CrowdsaleV2 {
  ICrowdsaleLock private _crowdsaleLock;

  constructor(
    ICrowdsaleLock crowdsaleLock_,
    IERC20 saleToken_,
    IERC20 fundingToken_,
    uint256 nativeRate_,
    uint256 erc20Rate_
  ) CrowdsaleV2(saleToken_, fundingToken_, nativeRate_, erc20Rate_) {
    require(
      address(crowdsaleLock_) != address(0),
      "LockableCrowdsale: crowdsaleLock cannot be zero address"
    );

    _crowdsaleLock = crowdsaleLock_;
  }

  function setCrowdsaleLock(ICrowdsaleLock crowdsaleLock_) external onlyOwner {
    require(
      address(crowdsaleLock_) != address(0),
      "LockableCrowdsale: crowdsaleLock cannot be zero address"
    );
    require(
      crowdsaleLock_ != _crowdsaleLock,
      "LockableCrowdsale: crowdsaleLock cannot be the same"
    );

    _crowdsaleLock = crowdsaleLock_;
  }
}
