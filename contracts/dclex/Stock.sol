// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "./Security.sol";
import "../libs/Model.sol";
import "../interfaces/IStock.sol";
import "../interfaces/IDID.sol";
import "../interfaces/ISignatureUtils.sol";
import "../interfaces/IFactory.sol";

/// @title Stocks token contract
contract Stock is Security, IStock, ERC20Permit {
    IFactory private _factory;
    // private _name and _symbol fields are also defined in the openzeppelin ERC20 implementation, but they are not accessible here
    string private _name;
    string private _symbol;

    /// @notice security properties in case of stock split
    uint256 private mNumerator = 1;
    uint256 private mDenominator = 1;

    constructor(
        string memory name_,
        string memory symbol_,
        address factory_
    ) ERC20Permit(name_) ERC20("", "") {
        _factory = IFactory(factory_);
        _name = name_;
        _symbol = symbol_;
    }

    /// @notice Mints Stocks tokens to selected address. Only executed by factory
    /// @param account receiving stocks
    /// @param amount of stocks to mint
    function mintTo(
        address account,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        _mint(account, amount);
    }

    /// @notice Burns Stocks tokens from selected address. Only executed by factory
    /// @param account depositing stocks to DCLEX
    /// @param amount of stocks to burn
    function burnFrom(
        address account,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(account, amount);
    }

    /// @notice Overrides ERC-20 transfer by DID verification
    /// @param to which address perform transfer
    /// @param amount of stocks to transfer
    function transfer(
        address to,
        uint256 amount
    )
        public
        override(IERC20, ERC20)
        checkTransferActors(msg.sender, to, amount)
        whenNotPaused
        returns (bool)
    {
        return super.transfer(to, amount);
    }

    /// @notice Overrides ERC-20 transfer by DID verification
    /// @param from which address perform a transfer
    /// @param to which address perform transfer
    /// @param amount of stocks to transfer
    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        override(IERC20, ERC20)
        whenNotPaused
        checkTransferActors(from, to, amount)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }

    /// @notice Security function to transfer from lost account. Only executed by factory
    /// @param from which address perform a transfer
    /// @param to which address perform transfer
    /// @param amount of stocks to transfer
    /// @dev we skip FROM checks since the account may be already invalidated
    function forceTransfer(
        address from,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!DID().isValid(DID().getId(to))) revert InvalidDID();
        _transfer(from, to, amount);
    }

    /// @notice Security function in case of mistakenly transferred tokens to this address. Executed by admin
    /// @param token address
    /// @param to receiver
    /// @param amount of tokens to transfer
    function emergencyTokenWithdrawal(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        if (token == address(0)) {
            to.call{value: amount}("");
        } else {
            IERC20(token).transfer(to, amount);
        }
    }

    /// @notice Security function in case of real stocks split. Executed by factory
    /// @param numerator for multiplication
    /// @param denominator for division
    function setMultiplier(
        uint256 numerator,
        uint256 denominator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (numerator == 0) revert MultiplyByZero();
        if (denominator == 0) revert DivideByZero();
        mNumerator = numerator;
        mDenominator = denominator;
    }

    function changeSymbol(
        string calldata symbol_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _symbol = symbol_;
    }

    function changeName(
        string calldata name_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _name = name_;
    }

    function multiplier() external view returns (uint256, uint256) {
        return (mNumerator, mDenominator);
    }

    function issuer() external pure returns (string memory) {
        return "dclex";
    }

    function name() public view override(ERC20) returns (string memory) {
        return _name;
    }

    function symbol()
        public
        view
        override(ERC20, IStock)
        returns (string memory)
    {
        return _symbol;
    }

    function DID() public view returns (IDID) {
        return _factory.getDID();
    }

    // @dev Modifiers
    modifier checkTransferActors(
        address from,
        address to,
        uint256 amount
    ) {
        if (!DID().verifyTransfer(from, to, amount)) {
            revert InvalidDID();
        }
        _;
    }
}
