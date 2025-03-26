// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "./Security.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../libs/Model.sol";
import "../interfaces/ISignatureUtils.sol";
import "../libs/Events.sol";

/// @title Vault factory allowing to deposit and withdraw USDC tokens
contract Vault is Security {
    /// @notice random numbers in signed structs to prevent double spending
    mapping(uint256 => uint256) private nonces;

    IERC20 private USDC;
    ISignatureUtils private utils;

    constructor(address _usdc, address _utils) {
        require(_usdc != address(0));
        require(_utils != address(0));
        USDC = IERC20(_usdc);
        utils = ISignatureUtils(_utils);
    }

    /// @notice Withdraws USDC from Vault to selected address. Executed only by admin
    /// @param to which address perform transfer
    /// @param amount of tokens to transfer
    function withdrawAdmin(
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        USDC.transfer(to, amount);
    }

    /// @notice Withdraws USDC from Vault to selected address. Requires signature from backend. Called by users
    /// @param withdrawal struct
    /// @param signature from backend
    function withdraw(
        Withdrawal calldata withdrawal,
        bytes calldata signature
    ) external nonReentrant whenNotPaused {
        if (nonces[withdrawal.nonce] == TRUE) revert InvalidNonce();
        address _USDC = address(USDC);
        if (withdrawal.token != _USDC) revert NotUSDC();
        if (withdrawal.account != address(this)) revert InvalidFromAddress();
        if (withdrawal.to != msg.sender) revert InvalidToAddress();
        if (IERC20(_USDC).balanceOf(address(this)) < withdrawal.amount)
            revert WrongAmount();

        address creator = utils.recoverWithdrawal(withdrawal, signature);
        if (!hasRole(DEFAULT_ADMIN_ROLE, creator)) revert WrongSignature();

        nonces[withdrawal.nonce] = TRUE;

        IERC20(_USDC).transfer(withdrawal.to, withdrawal.amount);

        emit Events.Withdraw(
            withdrawal.to,
            withdrawal.amount,
            withdrawal.nonce
        );
    }

    /// @notice Security function for withrawal mistakenly transferred tokens. Executed by master admin only
    /// @param token address to withraw
    /// @param to which address perform transfer
    /// @param amount of tokens to transfer
    function emergencyWithdrawalAdmin(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(MASTER_ADMIN_ROLE) nonReentrant {
        if (token == address(USDC)) revert NotUSDC();
        if (token == address(0)) {
            to.call{value: amount}("");
        } else {
            IERC20(token).transfer(to, amount);
        }
    }

    /// @notice Security function for withrawal mistakenly transferred tokens. Executed by users, requires signature from backend
    /// @param withdrawal struct
    /// @param signature from backend
    function emergencyWithdrawal(
        Withdrawal calldata withdrawal,
        bytes memory signature
    ) external nonReentrant {
        if (nonces[withdrawal.nonce] == TRUE) revert InvalidNonce();
        address creator = utils.recoverWithdrawal(withdrawal, signature);
        if (withdrawal.account != address(this)) revert InvalidFromAddress();
        if (withdrawal.token == address(USDC)) revert NotUSDC();
        if (!hasRole(DEFAULT_ADMIN_ROLE, creator)) revert WrongSignature();

        nonces[withdrawal.nonce] = TRUE;

        if (withdrawal.token == address(0)) {
            withdrawal.to.call{value: withdrawal.amount}("");
        } else {
            IERC20(withdrawal.token).transfer(withdrawal.to, withdrawal.amount);
        }
        emit Events.EmergencyWithdrawal(
            withdrawal.token,
            withdrawal.account,
            withdrawal.to,
            withdrawal.amount,
            withdrawal.nonce
        );
    }

    /// @notice Security function to invalidate signatures
    /// @param _nonces nonces for invalidation
    function useNonces(
        uint256[] calldata _nonces
    ) external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = _nonces.length;
        for (uint256 i = 0; i < len; ) {
            if (nonces[_nonces[i]] == TRUE) {
                continue;
            }
            nonces[_nonces[i]] = TRUE;
            emit Events.WithdrawalCancelled(_nonces[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice check if nonce was used
    /// @param nonce nonce to check
    /// @return 0, 1, 2...
    function getNonce(uint256 nonce) external returns (uint256) {
        return nonces[nonce];
    }
}
