// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "./IDID.sol";

interface IFactory {
    function getDID() external view returns (IDID);
}
