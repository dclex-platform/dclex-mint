// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "./Stock.sol";
import "../interfaces/ITokenBuilder.sol";
import {MASTER_ADMIN_ROLE} from "../libs/Model.sol";

/// @title Contract holding Stocks implementation
/// @notice Allows creating new stocks token by factory
contract TokenBuilder is ITokenBuilder {
    address private immutable factory;

    constructor(address _factory) {
        require(_factory != address(0));
        factory = _factory;
    }

    /// @notice Create new Stocks instance. Emits symbol and token contract address. Only called by factory
    /// @param name of token
    /// @param symbol of token
    function createToken(
        string memory name,
        string memory symbol
    ) external returns (address) {
        address _factory = factory;
        require(msg.sender == factory);
        Stock stock = new Stock(name, symbol, _factory);
        stock.grantRole(0x00, _factory);
        stock.grantRole(MASTER_ADMIN_ROLE, _factory);
        stock.revokeRole(0x00, address(this));
        stock.revokeRole(MASTER_ADMIN_ROLE, address(this));
        return address(stock);
    }

    function getFactory() external view returns (address) {
        return factory;
    }
}
