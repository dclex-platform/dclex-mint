// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "../libs/Model.sol";

interface ISignatureUtils {
    function recoverMint(
        Mint calldata mint,
        bytes calldata signature
    ) external view returns (address);

    function recoverBurn(
        Burn calldata mint,
        bytes calldata signature
    ) external view returns (address);

    function recoverMintDID(
        MintDID calldata mint,
        bytes calldata signature
    ) external view returns (address);

    function recoverWithdrawal(
        Withdrawal calldata withdrawal,
        bytes calldata signature
    ) external view returns (address);

    function recoverTransfer(
        Transfer calldata transfer,
        bytes calldata signature
    ) external view returns (address);

    function recoverTransferDID(
        TransferDID calldata transfer,
        bytes calldata signature
    ) external view returns (address);
}
