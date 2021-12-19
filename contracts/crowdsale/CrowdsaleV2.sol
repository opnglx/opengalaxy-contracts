// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CrowdsaleV2 is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  IERC20 private _saleToken;
  IERC20 private _fundingToken;

  uint256 private _nativeRate;
  uint256 private _erc20Rate;

  // Amount of wei raised
  uint256 private _totalRaised;

  constructor(
    IERC20 saleToken_,
    IERC20 fundingToken_,
    uint256 nativeRate_,
    uint256 erc20Rate_
  ) {
    require(
      address(saleToken_) != address(0),
      "Crowdsale: saleToken cannot be zero address"
    );
    require(
      address(fundingToken_) != address(0),
      "Crowdsale: fundingToken cannot be zero address"
    );
    require(
      address(fundingToken_) != address(saleToken_),
      "Crowdsale: saleToken and fundingToken cannot be the same"
    );
    require(nativeRate_ > 0, "Crowdsale: nativeRate is 0");
    require(erc20Rate_ > 0, "Crowdsale: erc20Rate is 0");

    _saleToken = saleToken_;
    _fundingToken = fundingToken_;
    _nativeRate = nativeRate_;
    _erc20Rate = erc20Rate_;
  }

  receive() external payable {
    buyTokens();
  }

  function saleToken() public view returns (IERC20) {
    return _saleToken;
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

  function totalRaised() public view returns (uint256) {
    return _totalRaised;
  }

  function buyTokens() public payable nonReentrant {
    require(msg.value > 0, "Crowdsale msg.value is 0");

    uint256 amount = msg.value;
    // calculate token amount to be created
    uint256 tokens = amount * nativeRate();
    // update state
    _totalRaised += amount;

    _saleToken.safeTransfer(msg.sender, tokens);
  }

  function buyTokens(uint256 amount) public nonReentrant {
    require(amount > 0, "Crowdsale: amount is 0");

    // calculate token amount to be created
    uint256 tokens = amount * erc20Rate();
    
    _fundingToken.safeTransferFrom(msg.sender, address(this), amount);

    // update state
    _totalRaised += amount;

    _saleToken.safeTransfer(msg.sender, tokens);
  }

  function setNativeRate(uint256 nativeRate_) external onlyOwner {
    require(nativeRate_ > 0, "Crowdsale: nativeRate is 0");
    require(nativeRate_ != nativeRate(), "Crowdsale: nativeRate is the same");

    _nativeRate = nativeRate_;
  }

  function setErc20Rate(uint256 erc20Rate_) external onlyOwner {
    require(erc20Rate_ > 0, "Crowdsale: erc20Rate is 0");
    require(erc20Rate_ != erc20Rate(), "Crowdsale: erc20Rate is the same");

    _erc20Rate = erc20Rate_;
  }

  function withdrawSaleToken(address beneficiary) external onlyOwner {
    require(
      beneficiary != address(0),
      "Crowdsale: beneficiary cannot be zero address"
    );

    uint256 amount = _saleToken.balanceOf(address(this));

    _saleToken.safeTransfer(beneficiary, amount);
  }

  function withdrawNative(address beneficiary) external onlyOwner {
    require(
      beneficiary != address(0),
      "Crowdsale: beneficiary cannot be zero address"
    );

    uint256 amount = address(this).balance;

    payable(beneficiary).transfer(amount);
  }

  function withdrawFundingToken(address beneficiary) external onlyOwner {
    require(
      beneficiary != address(0),
      "Crowdsale: beneficiary cannot be zero address"
    );

    uint256 amount = _fundingToken.balanceOf(address(this));

    _fundingToken.safeTransfer(beneficiary, amount);
  }
}
