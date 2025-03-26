// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {MASTER_ADMIN_ROLE} from "../libs/Model.sol";

/// @title Abstract Security contract with admin roles, reentrancy guard and pausable interface
abstract contract Security is AccessControl, Pausable, ReentrancyGuard {
    constructor() {
        _grantRole(MASTER_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, MASTER_ADMIN_ROLE);
        _setRoleAdmin(MASTER_ADMIN_ROLE, MASTER_ADMIN_ROLE);
    }

    function pause() external onlyRole(MASTER_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MASTER_ADMIN_ROLE) {
        _unpause();
    }

    function hasRole(
        bytes32 role,
        address account
    ) public view override returns (bool) {
        return super.hasRole(role, account);
    }
}
