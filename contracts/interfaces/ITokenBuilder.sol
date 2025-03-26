// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

interface ITokenBuilder {
    function createToken(
        string calldata name,
        string calldata symbol
    ) external returns (address);

    function getFactory() external view returns (address);
}
