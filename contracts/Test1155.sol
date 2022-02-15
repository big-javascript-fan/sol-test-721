// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Test1155 is Ownable, ERC1155 {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;
    constructor() ERC1155("_") {
        _name = "Test1155 Contract";
        _symbol = "TSC";
    }

    /**
     * @dev external mint function only available for owner - testing purpose
     * @param _to wallet address to mint
     * @param _ids array of token id to mint
     * @param _amounts array of token amount corresponding to _ids array for minting
     */
    function mint(address _to, uint[] calldata _ids, uint[] calldata _amounts) external onlyOwner {
        _mintBatch(_to, _ids, _amounts, "");
    }

    /**
     * @dev See {IERC1155Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC1155Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

}