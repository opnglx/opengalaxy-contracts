// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CrowdsaleV2 is Ownable, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  IERC20 private _saleToken;
  IERC20 private _fundingToken;

  uint256 private _nativeRate;
  uint256 private _erc20Rate;

  // Amount of wei raised
  uint256 private _totalNativeRaised;
  uint256 private _totalErc20Raised;

  address private _operator;

  event TokensPurchased(
    address indexed purchaser,
    uint256 amount,
    uint256 tokens
  );

  event NativeRateChanged(uint256 nativeRate);

  event Erc20RateChanged(uint256 erc20Rate);

  event OperatorChanged(address operator);

  event SaleTokenWithdrawn(address beneficiary, uint256 amount);

  event NativeWithdrawn(address beneficiary, uint256 amount);

  event FundingTokenWithdrawn(address beneficiary, uint256 amount);

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
    _operator = owner();
  }

  modifier onlyOperator {
    require(msg.sender == _operator, "Crowdsale: caller is not the operator");
    _;
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

  function totalNativeRaised() public view returns (uint256) {
    return _totalNativeRaised;
  }

  function totalErc20Rasied() public view returns (uint256) {
    return _totalErc20Raised;
  }

  function operator() public view returns (address) {
    return _operator;
  }

  function buyTokens() public payable nonReentrant whenNotPaused {
    require(msg.value > 0, "Crowdsale msg.value is 0");

    uint256 amount = msg.value;
    // calculate token amount to be created
    uint256 tokens = amount * _nativeRate;
    // update state
    _totalNativeRaised += amount;

    _deliverTokens(msg.sender, tokens);

    emit TokensPurchased(msg.sender, amount, tokens);
  }

  function buyTokens(uint256 amount) public nonReentrant whenNotPaused {
    require(amount > 0, "Crowdsale: amount is 0");

    // calculate token amount to be created
    uint256 tokens = amount * _erc20Rate;

    _fundingToken.safeTransferFrom(msg.sender, address(this), amount);

    // update state
    _totalErc20Raised += amount;

    _deliverTokens(msg.sender, tokens);

    emit TokensPurchased(msg.sender, amount, tokens);
  }

  function setNativeRate(uint256 nativeRate_) external onlyOperator {
    require(nativeRate_ > 0, "Crowdsale: nativeRate is 0");
    require(nativeRate_ != _nativeRate, "Crowdsale: nativeRate is the same");

    _nativeRate = nativeRate_;

    emit NativeRateChanged(nativeRate_);
  }

  function setErc20Rate(uint256 erc20Rate_) external onlyOperator {
    require(erc20Rate_ > 0, "Crowdsale: erc20Rate is 0");
    require(erc20Rate_ != _erc20Rate, "Crowdsale: erc20Rate is the same");

    _erc20Rate = erc20Rate_;

    emit Erc20RateChanged(erc20Rate_);
  }

  function setOperator(address operator_) external onlyOwner {
    require(
      operator_ != address(0),
      "Crowdsale: operator cannot be zero address"
    );
    require(operator_ != _operator, "Crowdsale: operator is the same address");

    _operator = operator_;

    emit OperatorChanged(operator_);
  }

  function withdrawSaleToken(address beneficiary) external onlyOwner {
    require(
      beneficiary != address(0),
      "Crowdsale: beneficiary cannot be zero address"
    );

    uint256 amount = _saleToken.balanceOf(address(this));

    _saleToken.safeTransfer(beneficiary, amount);

    emit SaleTokenWithdrawn(beneficiary, amount);
  }

  function withdrawNative(address beneficiary) external onlyOwner {
    require(
      beneficiary != address(0),
      "Crowdsale: beneficiary cannot be zero address"
    );

    uint256 amount = address(this).balance;

    payable(beneficiary).transfer(amount);

    emit NativeWithdrawn(beneficiary, amount);
  }

  function withdrawFundingToken(address beneficiary) external onlyOwner {
    require(
      beneficiary != address(0),
      "Crowdsale: beneficiary cannot be zero address"
    );

    uint256 amount = _fundingToken.balanceOf(address(this));

    _fundingToken.safeTransfer(beneficiary, amount);

    emit FundingTokenWithdrawn(beneficiary, amount);
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function _deliverTokens(address beneficiary, uint256 amount)
    internal
    virtual
  {
    _saleToken.safeTransfer(beneficiary, amount);
  }
}
