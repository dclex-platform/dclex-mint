// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

interface ITransferVerifier {
    function verifyTransfer(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
