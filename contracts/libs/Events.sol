// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

library Events {
    /// @dev Stocks
    event StocksPaused(string symbol);
    event StocksUnpaused(string symbol);

    event StocksCreated(string indexed symbol, address tokenAddress);

    event Mint(
        string indexed symbol,
        address indexed account,
        uint256 amount,
        uint256 nonce
    );
    event Burn(
        string indexed symbol,
        address indexed account,
        uint256 amount,
        uint256 nonce
    );
    event MintCancelled(uint256 nonce);

    event ForceMint(
        string indexed symbol,
        address indexed account,
        uint256 amount,
        uint256 nonce
    );
    event ForceBurn(
        string indexed symbol,
        address indexed account,
        uint256 amount,
        uint256 nonce
    );

    event ChangeNameSymbol(
        address indexed token,
        string indexed oldSymbol,
        string indexed newSymbol,
        string name
    );
    event ChangeSymbol(
        address indexed token,
        string indexed oldSymbol,
        string indexed newSymbol
    );
    event ChangeName(address indexed token, string indexed symbol, string name);

    event MultiplierChanged(
        string indexed symbol,
        uint256 numerator,
        uint256 denominator
    );

    event ForceTransfer(
        string indexed symbol,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 nonce
    );

    event EmergencyWithdrawal(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 nonce
    );

    /// @dev Digital identites
    event MintDID(address indexed account, uint256 tokenId, bool isContract);
    event ChangeValid(uint256 indexed tokenId, bool indexed valid);
    event ChangePro(uint256 indexed tokenId, bool indexed isPro);

    /// @dev Vault
    event Withdraw(
        address indexed account,
        uint256 indexed amount,
        uint256 nonce
    );
    event WithdrawalCancelled(uint256 nonce);
}
