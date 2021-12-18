// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdsale is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // The token being sold
    IERC20 private _token;

    // Address where funds are collected
    address payable private _wallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 private _rate;

    // Amount of wei raised
    uint256 private _weiRaised;

    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    event RateChanged(uint256 rate);

    event WalletChanged(address indexed wallet);

    constructor(
        uint256 rate_,
        address payable wallet_,
        IERC20 token_
    ) {
        require(rate_ > 0, "Crowdsale: rate is 0");
        require(wallet_ != address(0), "Crowdsale: wallet is the zero address");
        require(
            address(token_) != address(0),
            "Crowdsale: token is the zero address"
        );

        _rate = rate_;
        _wallet = wallet_;
        _token = token_;
    }

    // Fallback function
    receive() external payable {
        buyTokens(_msgSender());
    }

    function token() public view returns (IERC20) {
        return _token;
    }

    function wallet() public view returns (address payable) {
        return _wallet;
    }

    function setWallet(address payable wallet_) external onlyOwner {
        require(wallet_ != address(0), "Crowdsale: wallet is the zero address");
        require(
            wallet_ != address(this),
            "Crowdsale: wallet cannot be a contract"
        );
        require(_wallet != wallet_, "Crowdsale: wallet is the same address");

        _wallet = wallet_;

        emit WalletChanged(_wallet);
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function setRate(uint256 rate_) external onlyOwner {
        require(rate_ > 0, "Crowdsale: rate is 0");
        require(_rate != rate_, "Crowdsale: rate are equals");

        _rate = rate_;

        emit RateChanged(_rate);
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function buyTokens(address beneficiary) public payable nonReentrant {
        uint256 weiAmount = _weiAmount();

        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised += weiAmount;

        _processPurchase(beneficiary, weiAmount);
        _deliverTokens(beneficiary, tokens);

        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }

    function withdrawTokens(uint256 tokenAmount) external onlyOwner {
        require(tokenAmount != 0, "Crowdsale: tokenAmount is 0");
        require(
            tokenAmount <= _token.balanceOf(address(this)),
            "Crowdsale: tokenAmount is grater than balance"
        );

        _token.safeTransfer(_msgSender(), tokenAmount);
    }

    function withdrawFunds(uint256 weiAmount) external virtual onlyOwner {
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(
            weiAmount <= address(this).balance,
            "Crowdsale: weiAmount exceeds balance"
        );

        _wallet.transfer(weiAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
        virtual
    {
        require(
            beneficiary != address(0),
            "Crowdsale: beneficiary is the zero address"
        );
        require(weiAmount != 0, "Crowdsale: value is 0");
    }

    function _processPurchase(address beneficiary, uint256 weiAmount)
        internal
        virtual
    {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _deliverTokens(address beneficiary, uint256 weiAmount)
        internal
        virtual
    {
        _token.safeTransfer(beneficiary, weiAmount);
    }

    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        return weiAmount * _rate;
    }

    // Calculates the amount of wei the user pays
    function _weiAmount() internal view virtual returns (uint256) {
        return msg.value;
    }
}
