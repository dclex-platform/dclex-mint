// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {MintDID} from "../libs/Model.sol";

interface IDID is IERC721 {
    function mint(
        MintDID calldata mintStruct,
        bytes calldata signature
    ) external;

    function mintAdmin(
        address account,
        string calldata uri,
        uint256 isPro,
        bytes32 data
    ) external;

    function burn(uint256 tokenId) external;

    function forceTransfer(address from, address to, uint256 tokenId) external;

    function isValid(uint256 id) external view returns (bool);

    function setValids(
        uint256[] calldata _ids,
        bool[] calldata isValids
    ) external;

    function setPros(uint256[] calldata _ids, bool[] calldata isPros) external;

    function isPro(uint256 id) external returns (bool);

    function setData(uint256 id, bytes32 data) external;

    function getData(uint256 id) external returns (bytes32);

    function getId(address owner) external view returns (uint256);

    function verifyTransfer(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
