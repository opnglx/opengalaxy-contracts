// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BEP20.sol";

contract GalaxyToken is BEP20 {

    string private constant _name = "Galaxy Token";
    string private constant _symbol = "GLXY";

    mapping (address => uint256) private initLockPeriodInQ;
    mapping (address => uint256) private unlockPeriodsInQ;
    mapping (address => uint256) private lockedAmount;
    mapping (address => uint256) private lockedTransferred;

    struct LockData {
      uint256 initLockPeriodInQ;
      uint256 unlockPeriodsInQ;
      uint256 lockedAmount;
      uint256 lockedTransferred;
    }

    mapping (address => LockData) private lockedTokens;

    mapping (address => bool) public isLocked;
    
    mapping (address => bool) private _isAuthorised;

    uint256 public constant MAX_SUPPPLY = 100000000 * 10**18; // 100mln tokens
    uint256 public lockTimestamp;
    uint256 private constant SECONDS_IN_DAY = 86400;
    uint256 private constant SECONDS_IN_Q = 91 * SECONDS_IN_DAY;

    event TokensLocked(
      uint256 initLockPeriod,
      uint256 unlockPeriod,
      uint256 lockAmount,
      address lockedAddress
    );

    modifier authorised {
      require(_isAuthorised[_msgSender()], "Not Authorised");
      _;
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() {
        lockTimestamp = block.timestamp;
        _mint(_msgSender(), MAX_SUPPPLY);
        _isAuthorised[_msgSender()] = true;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
      if (isLocked[from]) {
        LockData storage user = lockedTokens[from];

        uint256 tokensLocked = user.lockedAmount;
        uint256 amountTransferred = user.lockedTransferred;

        uint256 unlockedAmount = getUnlockedBalance(from);
        if (unlockedAmount == tokensLocked) { isLocked[from] = false; }

        uint256 leftLocked = tokensLocked - amountTransferred;
        uint256 lockedAvailableForTransfer = unlockedAmount - amountTransferred;
        uint256 freeAmount = balanceOf(from) - leftLocked;
        uint256 transferrableAmount = lockedAvailableForTransfer + freeAmount;

        require(transferrableAmount >= amount, "transfer more than available");

        uint256 addToLockedTransfered = freeAmount >= amount ? 0 : (amount - freeAmount);
        user.lockedTransferred += addToLockedTransfered;
      }
    }
    
    function lockTokens(uint256 initLock, uint256 unlockPeriod, uint256 amount, address walletAddress) public authorised {
      require(initLock <= 20, "initLock period should be less than 20");
      require(unlockPeriod >= 1 && unlockPeriod <= 20, "unlock period should be greater then 0");
      require(amount > 1*10**18, "cannot lock less than 1 token");
      require(!isLocked[walletAddress], "address already locked");
      require(balanceOf(walletAddress) >= amount, "insufficient balance for lock");

      lockedTokens[walletAddress] = LockData(
        initLock,
        unlockPeriod,
        amount,
        0
      );
      
      isLocked[walletAddress] = true;

      emit TokensLocked(initLock, unlockPeriod, amount, walletAddress);
    }

    function getUnlockedBalance(address walletAddress) internal view returns (uint256) {
      require(isLocked[walletAddress], "funds are not locked");
      LockData memory user = lockedTokens[walletAddress];

      uint256 unlockPeriods = user.unlockPeriodsInQ;
      uint256 initLock = user.initLockPeriodInQ;
      uint256 tokensLocked = user.lockedAmount;

      uint256 availableForTransfer;

      for (uint256 i = 0; i < unlockPeriods; i++) {
        uint256 tierUnlockTimestamp = lockTimestamp + SECONDS_IN_Q * initLock + SECONDS_IN_Q * i;
        if (block.timestamp > tierUnlockTimestamp) {
          availableForTransfer += tokensLocked / unlockPeriods;
        }
      }

      if (availableForTransfer % 10 != 0) { availableForTransfer += 1; }

      return availableForTransfer;
    }

    function getTransferableLockedAmount(address walletAddress) public view returns (uint256) {
      LockData memory user = lockedTokens[walletAddress];
      uint256 amountTransferred = user.lockedTransferred;

      return getUnlockedBalance(walletAddress) - amountTransferred;
    }

    function authorise(address addressToAuth) public onlyOwner {
      _isAuthorised[addressToAuth] = true;
    }

    function unauthorise(address addressToUnAuth) public onlyOwner {
      _isAuthorised[addressToUnAuth] = false;
    }
}
