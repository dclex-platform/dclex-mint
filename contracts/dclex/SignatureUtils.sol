// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../libs/Model.sol";
import "./Security.sol";

/// @title Signature signer recovery tool
/// @notice no access control required
contract SignatureUtils is EIP712 {
    constructor() EIP712("DCLEX", "1.0") {}

    function recoverMint(
        Mint calldata mint,
        bytes calldata signature
    ) external view returns (address) {
        return ECDSA.recover(hashMint(mint), signature);
    }

    function recoverBurn(
        Burn calldata burn,
        bytes calldata signature
    ) external view returns (address) {
        return ECDSA.recover(hashBurn(burn), signature);
    }

    function recoverMintDID(
        MintDID calldata mint,
        bytes calldata signature
    ) external view returns (address) {
        return ECDSA.recover(hashMintDID(mint), signature);
    }

    function recoverWithdrawal(
        Withdrawal calldata withdrawal,
        bytes calldata signature
    ) external view returns (address) {
        return ECDSA.recover(hashWithdrawal(withdrawal), signature);
    }

    function recoverTransfer(
        Transfer calldata transfer,
        bytes calldata signature
    ) external view returns (address) {
        return ECDSA.recover(hashTransfer(transfer), signature);
    }

    function recoverTransferDID(
        TransferDID calldata transfer,
        bytes calldata signature
    ) external view returns (address) {
        return ECDSA.recover(hashTransferDID(transfer), signature);
    }

    function hashMint(Mint calldata mint) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Mint(string symbol,uint256 amount,address account,uint256 nonce)"
                        ),
                        keccak256(abi.encodePacked(mint.symbol)),
                        mint.amount,
                        mint.account,
                        mint.nonce
                    )
                )
            );
    }

    function hashBurn(Burn calldata burn) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Burn(string symbol,uint256 amount,address account,uint256 nonce)"
                        ),
                        keccak256(abi.encodePacked(burn.symbol)),
                        burn.amount,
                        burn.account,
                        burn.nonce
                    )
                )
            );
    }

    function hashMintDID(MintDID calldata mint) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "MintDID(address account,uint256 nonce,uint256 isPro,bytes32 data)"
                        ),
                        mint.account,
                        mint.nonce,
                        mint.isPro,
                        mint.data
                    )
                )
            );
    }

    function hashWithdrawal(
        Withdrawal calldata withdrawal
    ) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Withdrawal(address token,address account,address to,uint256 amount,uint256 nonce)"
                        ),
                        withdrawal.token,
                        withdrawal.account,
                        withdrawal.to,
                        withdrawal.amount,
                        withdrawal.nonce
                    )
                )
            );
    }

    function hashTransfer(
        Transfer calldata transfer
    ) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "Transfer(string symbol,address account,address to,uint256 amount,uint256 nonce)"
                        ),
                        keccak256(abi.encodePacked(transfer.symbol)),
                        transfer.account,
                        transfer.to,
                        transfer.amount,
                        transfer.nonce
                    )
                )
            );
    }

    function hashTransferDID(
        TransferDID calldata transfer
    ) private view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "TransferDID(uint256 id,address account,address to,uint256 nonce)"
                        ),
                        transfer.id,
                        transfer.account,
                        transfer.to,
                        transfer.nonce
                    )
                )
            );
    }
}
