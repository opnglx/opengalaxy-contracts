// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Crowdsale is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  IERC20 private _token;
  IERC20 private _fundingToken;

  uint256 private _nativeRate;
  uint256 private _erc20Rate;

  // Amount of wei raised
  uint256 private _weiRaised;

  constructor(
    IERC20 token_,
    IERC20 fundingToken_,
    uint256 nativeRate_,
    uint256 erc20Rate_
  ) {
    require(
      address(token_) != address(0),
      "Crowdsale: token cannot be zero address"
    );
    require(
      address(fundingToken_) != address(0),
      "Crowdsale: fundingToken cannot be zero address"
    );
    require(
      address(fundingToken_) != address(token_),
      "Crowdsale: token and fundingToken cannot be the same"
    );
    require(nativeRate_ > 0, "Crowdsale: nativeRate is 0");
    require(erc20Rate_ > 0, "Crowdsale: erc20Rate is 0");

    _token = token_;
    _fundingToken = fundingToken_;
    _nativeRate = nativeRate_;
    _erc20Rate = erc20Rate_;
  }

  receive() external payable {
    buyTokens();
  }

  function token() public view returns (IERC20) {
    return _token;
  }

  function fundingToken() public view returns (IERC20) {
    return _fundingToken;
  }

  function nativeRate() public view returns (uint256) {
    return _nativeRate;
  }

  function erc20Rate() public view returns (uint256) {
    return _erc20Rate;
  }

  function buyTokens() public payable nonReentrant {
    require(msg.value > 0, "Crowdsale msg.value is 0");

    uint256 weiAmount = msg.value;
    // calculate token amount to be created
    uint256 tokens = weiAmount * nativeRate();
    // update state
    _weiRaised += weiAmount;

    token().safeTransfer(msg.sender, tokens);
  }

  function buyTokens(uint256 weiAmount) public nonReentrant {
    require(weiAmount > 0, "Crowdsale: weiAmount is 0");

    // calculate token amount to be created
    uint256 tokens = weiAmount * erc20Rate();
    // TODO: refactor
    fundingToken().safeTransferFrom(msg.sender, address(this), weiAmount);

    // update state
    _weiRaised += weiAmount;

    token().safeTransfer(msg.sender, tokens);
  }
}
