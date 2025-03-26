// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "./Security.sol";
import "../interfaces/IStock.sol";
import "../libs/Events.sol";
import "../libs/Model.sol";
import "../interfaces/ISignatureUtils.sol";
import "../interfaces/IDID.sol";
import "../interfaces/ISecurity.sol";
import "../interfaces/ITokenBuilder.sol";
import "../interfaces/IFactory.sol";

/// @title Factory and management functions for stocks, used by admin and users
/// @notice You can use this contract for only the most basic simulation
contract Factory is Security, IFactory {
    /// @notice random numbers in signed structs to prevent double spending
    mapping(uint256 => uint256) private nonces;

    /// @notice mapping symbols to token addresses
    mapping(string => address) public stocks;

    /// @notice list of token symbols
    string[] public symbols;

    /// @notice interfaces of dependent contracts
    ISignatureUtils private immutable utils;
    ITokenBuilder private builder;
    IDID private DID;

    constructor(address _utils) {
        utils = ISignatureUtils(_utils);
    }

    /// @notice Create new Stocks instance. Emits symbol and token contract address. Called only by admin
    /// @param name of token
    /// @param symbol of token
    function createStocks(
        string calldata name,
        string calldata symbol
    ) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        if (stocks[symbol] != address(0)) revert StockAlreadyExists();
        address newToken = builder.createToken(name, symbol);
        symbols.push(symbol);
        stocks[symbol] = newToken;

        emit Events.StocksCreated(symbol, newToken);
    }

    /// @notice Mints stocks, used by master admin
    /// @param symbol of stocks
    /// @param account receiving stocks
    /// @param amount of tokens to be minted
    function forceMintStocks(
        string calldata symbol,
        address account,
        uint256 amount
    ) external onlyRole(MASTER_ADMIN_ROLE) {
        IStock(stocks[symbol]).mintTo(account, amount);
        emit Events.ForceMint(symbol, account, amount, 0);
    }

    /// @notice Burns stocks from selected account, used by master admin
    /// @param symbol of stocks
    /// @param account from which tokens are burned
    /// @param amount of burned stocks
    function forceBurnStocks(
        string calldata symbol,
        address account,
        uint256 amount
    ) external onlyRole(MASTER_ADMIN_ROLE) {
        address _token = stocks[symbol];
        if (_token == address(0)) revert StockNotExists();
        IStock(_token).burnFrom(account, amount);
        emit Events.ForceBurn(symbol, account, amount, 0);
    }

    /// @notice Mints stocks (withdraw from DCLEX app) with struct signed by backend. Only address matching user in the app can execute
    /// @param mint struct
    /// @param signature from backend
    function mintStocks(
        Mint calldata mint,
        bytes calldata signature
    ) external whenNotPaused {
        if (msg.sender != mint.account) revert InvalidSender();

        address _token = stocks[mint.symbol];

        if (_token == address(0)) revert StockNotExists();
        if (nonces[mint.nonce] == TRUE) revert InvalidNonce();

        address creator = utils.recoverMint(mint, signature);

        if (!hasRole(DEFAULT_ADMIN_ROLE, creator)) revert WrongSignature();

        nonces[mint.nonce] = TRUE;

        IStock(_token).mintTo(mint.account, mint.amount);

        emit Events.Mint(mint.symbol, mint.account, mint.amount, mint.nonce);
    }

    /// @notice Burns stocks (deposit to DCLEX app) with struct signed by backend. Only address matching user in the app can execute
    /// @param burn struct
    /// @param signature from backend
    function burnStocks(
        Burn calldata burn,
        bytes calldata signature
    ) external whenNotPaused {
        if (msg.sender != burn.account) revert InvalidSender();

        address _token = stocks[burn.symbol];

        if (_token == address(0)) revert StockNotExists();
        if (nonces[burn.nonce] == TRUE) revert InvalidNonce();

        address creator = utils.recoverBurn(burn, signature);

        if (!hasRole(DEFAULT_ADMIN_ROLE, creator)) revert WrongSignature();

        nonces[burn.nonce] = TRUE;

        IStock(_token).burnFrom(burn.account, burn.amount);
        emit Events.Burn(burn.symbol, burn.account, burn.amount, burn.nonce);
    }

    /// @notice Security function in case user changes the assigned address in the app. Requires signature from backend.
    /// @param transfer struct
    /// @param signature from backend
    function forceTransfer(
        Transfer calldata transfer,
        bytes calldata signature
    ) external {
        address _token = stocks[transfer.symbol];

        if (_token == address(0)) revert StockNotExists();
        if (nonces[transfer.nonce] == TRUE) revert InvalidNonce();

        address creator = utils.recoverTransfer(transfer, signature);
        if (!hasRole(DEFAULT_ADMIN_ROLE, creator)) revert WrongSignature();
        nonces[transfer.nonce] = TRUE;

        IStock(_token).forceTransfer(
            transfer.account,
            transfer.to,
            transfer.amount
        );
        emit Events.ForceTransfer(
            transfer.symbol,
            transfer.account,
            transfer.to,
            transfer.amount,
            transfer.nonce
        );
    }

    function changeSymbol(
        string calldata oldSymbol,
        string calldata newSymbol
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (stocks[newSymbol] != address(0)) revert StockAlreadyExists();
        IStock(stocks[oldSymbol]).changeSymbol(newSymbol);
        stocks[newSymbol] = stocks[oldSymbol];
        symbols.push(newSymbol);
        emit Events.ChangeSymbol(stocks[newSymbol], oldSymbol, newSymbol);
    }

    function changeName(
        string calldata symbol,
        string calldata name
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IStock(stocks[symbol]).changeName(name);
        emit Events.ChangeName(stocks[symbol], symbol, name);
    }

    /// @notice Security function in case of hardfork or disabling the service.
    /// @param _symbols of tokens to pause
    function pauseStocks(
        string[] calldata _symbols
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = _symbols.length;
        for (uint256 i = 0; i < len; ) {
            ISecurity(stocks[_symbols[i]]).pause();
            emit Events.StocksPaused(_symbols[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Security function in case of hardfork or disabling the service.
    /// @param _symbols of tokens to unpause
    function unpauseStocks(
        string[] calldata _symbols
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = _symbols.length;
        for (uint256 i = 0; i < len; ) {
            ISecurity(stocks[_symbols[i]]).unpause();
            emit Events.StocksUnpaused(_symbols[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Security function in case of real stocks split
    /// @param symbol of stocks
    /// @param numerator for multiplication
    /// @param denominator for division
    function setStockMultiplier(
        string calldata symbol,
        uint256 numerator,
        uint256 denominator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address _token = stocks[symbol];

        if (_token == address(0)) revert StockNotExists();
        IStock(_token).setMultiplier(numerator, denominator);
        emit Events.MultiplierChanged(symbol, numerator, denominator);
    }

    /// @notice Security function in case of mistakenly transferred tokens
    /// @param withdrawal struct
    /// @param signature from backend
    function emergencyWithdrawal(
        Withdrawal calldata withdrawal,
        bytes calldata signature
    ) external {
        address creator = utils.recoverWithdrawal(withdrawal, signature);
        if (!hasRole(DEFAULT_ADMIN_ROLE, creator)) revert WrongSignature();
        if (nonces[withdrawal.nonce] == TRUE) revert InvalidNonce();

        nonces[withdrawal.nonce] = TRUE;

        if (withdrawal.account == address(this)) {
            if (withdrawal.token == address(0)) {
                withdrawal.to.call{value: withdrawal.amount}("");
            } else {
                IERC20(withdrawal.token).transfer(
                    withdrawal.to,
                    withdrawal.amount
                );
            }
        } else {
            if (
                stocks[IStock(withdrawal.account).symbol()] == address(0) &&
                (withdrawal.account != address(DID))
            ) revert StockNotExists();
            IStock(withdrawal.account).emergencyTokenWithdrawal(
                withdrawal.token,
                withdrawal.to,
                withdrawal.amount
            );
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
            emit Events.MintCancelled(_nonces[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice check if nonce was used
    /// @param nonce nonce to check
    /// @return 0, 1, 2...
    function getNonce(uint256 nonce) external view returns (uint256) {
        return nonces[nonce];
    }

    /// @notice Setter for token builder. Needs to set the factory first on builder side
    /// @param _builder address
    function setTokenBuilder(
        address _builder
    ) external onlyRole(MASTER_ADMIN_ROLE) {
        require(ITokenBuilder(_builder).getFactory() == address(this));
        //  "DCLEX: Factory is not set for builder properly"
        builder = ITokenBuilder(_builder);
    }

    function getDID() external view returns (IDID) {
        return DID;
    }

    function setDID(address _did) external onlyRole(MASTER_ADMIN_ROLE) {
        require(_did != address(0));
        DID = IDID(_did);
    }

    function getStocksCount() external view returns (uint256) {
        // TODO: symbols might contain duplicated stocks
        return symbols.length;
    }
}
