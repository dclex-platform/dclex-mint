// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

/// @dev Roles
bytes32 constant MASTER_ADMIN_ROLE = keccak256("MASTER_ADMIN_ROLE");

/// @dev bool constants
uint256 constant TRUE = 1;
uint256 constant FALSE = 2;

/// @dev Signable structs
struct Mint {
    string symbol; // stocks symbol
    uint256 amount; // amount of minted stocks
    address account; // to whom stocks should be minted
    uint256 nonce;
}

struct Burn {
    string symbol; // stocks symbol
    uint256 amount; // amount of burned stocks
    address account; // from who stocks should be burned
    uint256 nonce;
}

struct MintDID {
    address account; // to whom KYC should be minted
    uint256 nonce;
    uint256 isPro;
    bytes32 data;
}

struct Withdrawal {
    address token; // what token to be transferred
    address account; // from what address
    address to; // to what address
    uint256 amount;
    uint256 nonce;
}

struct Transfer {
    string symbol;
    address account;
    address to;
    uint256 amount;
    uint256 nonce;
}

struct TransferDID {
    uint256 id;
    address account;
    address to;
    uint256 nonce;
}

/// @dev Errors

/// Common
error WrongSignature();
error InvalidNonce();
error InvalidSender();
error WrongArrayLengths();
error NotAllowed();

/// Factory
error StockAlreadyExists();
error StockNotExists();

/// DID
error AlreadyHasDID();

/// Stocks
error InvalidDID();
error DivideByZero();
error MultiplyByZero();

/// Vault
error NotUSDC(); // depending on condition: should be USDC or should not be
error InvalidFromAddress();
error InvalidToAddress();
error WrongAmount();
