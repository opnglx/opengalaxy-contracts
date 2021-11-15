// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BEP20.sol";

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of BEP20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract GalaxyToken is BEP20 {

    string private constant _name = "Galaxy Token";
    string private constant _symbol = "GLXY";

    uint256 public lockTimestamp;

    uint256 public constant MAX_SUPPPLY = 100000000 * 10**18; // 100mln tokens
    uint256 private constant SECONDS_IN_DAY = 86400;
    uint256 private constant SECONDS_IN_Q = 91 * SECONDS_IN_DAY;

    struct LockData {
      uint256 initLockPeriodInQ;
      uint256 unlockPeriodsInQ;
      uint256 lockedAmount;
      uint256 lockedTransferred;
    }

    mapping (address => LockData) private lockedTokens;

    mapping (address => bool) public isLocked;
    
    mapping (address => bool) private _isAuthorised;

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
        amountTransferred += addToLockedTransfered;
      }
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
