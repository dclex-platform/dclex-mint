// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

interface ISecurity {
    function pause() external;

    function unpause() external;

    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);
}
