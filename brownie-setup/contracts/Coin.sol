// SPDX-License-Identifier: MIT
/// @author KRogLA (https://github.com/krogla)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "./lib/ERC20Hooks.sol";
import "./lib/errors.sol";

/**
 * @dev {ERC20} Coin token
 */
contract Coin is AccessControlEnumerable, Pausable, ERC20Burnable,  ERC20Hooks {
    bytes32 public constant MANAGE_ROLE = keccak256("MANAGE_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address initialHolder
    ) ERC20(name, symbol) {
        if (initialHolder == address(0)) revert ZeroAddress();
        if (initialSupply == 0) revert ZeroAmount();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGE_ROLE, _msgSender());

        _setupRole(MANAGE_ROLE, initialHolder);
        _mint(initialHolder, initialSupply);
    }


    /**
     * @dev Pauses all token transfers.
     */
    function pause() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     */
    function unpause() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev See {ERC20Hooks-_enableHooks}.
     */
    function enableHooks(bool enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _enableHooks(enabled);
    }

    /**
     * @dev See {ERC20Hooks-_addHook}.
     */
    function addHook(address hook) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addHook(hook);
    }

    /**
     * @dev See {ERC20Hooks-_removeHook}.
     */
    function removeHook(address hook) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _removeHook(hook);
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (to == address(this)) revert TransferToTokenContract();

        if (paused()) revert TransferWhilePaused();

        _applyHooks(_msgSender(), from, to, amount);
    }

    /**
     * @dev Revoke tokens from the accounts of "bad players" marked as "blocked" by a hook
     * @notice During a call, all hooks will be temporarily disabled
     */
    function revokeBlocked(
        address hook,
        address revokeTo,
        address[] memory holders
    ) external onlyRole(DEFAULT_ADMIN_ROLE) withoutHooks {
        if (!hookExists(hook)) revert NotExists();
        bool[] memory blocked = IHook(hook).getBlocked(holders);
        if (blocked.length != holders.length) revert HookWrongRespond();
        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            if (blocked[i]) {
                _transfer(holders[i], revokeTo, balanceOf(holder));
            }
        }
    }
}
