// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./TestAccessControl.sol";

contract Test721 is ERC721, Ownable {
    using Address for address;
    using Strings for uint256;

    /// @dev Token name
    string private _name;

    /// @dev Token symbol
    string private _symbol;

    /// @notice Attribute data structure
    struct Attribute {
        address erc1155Address;
        uint    erc1155TokenId;
    }

    /// @notice Transfer history
    struct TransferHistory {
        address erc1155Address;
        uint erc1155TokenId;
        uint amount;
        uint erc721TokenId;
        string s;
        address originAddress;
    }

    /// @notice extensible attributes array
    mapping(uint => mapping(string => Attribute)) public attributes;

    /// @notice transfer history array
    mapping(address => TransferHistory[]) public transferHistories;

    /// @notice AccessControl contract instance
    TestAccessControl public accessControl;

    /// --------- Events ---------- ///
    event SetAttribute(uint token721Id, address erc1155Address, uint amount, uint token1155Id, string s, string eventType);

    constructor(
        TestAccessControl _accessControl
    ) ERC721("Test721 Contract", "T721") {
        accessControl = _accessControl;
    }

    function setAttribute(string calldata s, address _erc1155Address, uint _token1155Id, uint _token721Id) external {
        require(accessControl.hasAttributeManagerRole(msg.sender), "Need to be attribute manager role to set attribute");

        Attribute memory attribute = attributes[_token721Id][s];

        if(_erc1155Address == address(0) && _token1155Id == 0) {
            TransferHistory[] storage individualHistories = transferHistories[msg.sender];
            require(individualHistories.length > 0, "There was no transfer from this account to be returned");

            TransferHistory storage lastHistory = individualHistories[individualHistories.length - 1];
            IERC1155(lastHistory.erc1155Address).safeTransferFrom(owner(), lastHistory.originAddress, lastHistory.erc1155TokenId, lastHistory.amount, "");

            emit SetAttribute(_token721Id, _erc1155Address, lastHistory.amount, _token1155Id, s, "Zero Return");

            individualHistories.pop();
            delete attributes[_token721Id][s];
        }

        if(attribute.erc1155Address == _erc1155Address && attribute.erc1155TokenId == _token1155Id) {
            uint balance = IERC1155(_erc1155Address).balanceOf(address(this), _token1155Id);
            IERC1155(_erc1155Address).safeTransferFrom(address(this), owner(), _token1155Id, balance, "");
            TransferHistory[] storage individualHistories = transferHistories[msg.sender];
            individualHistories.push(
                TransferHistory(_erc1155Address, _token1155Id, balance, _token721Id, s, msg.sender)
            );

            emit SetAttribute(_token721Id, _erc1155Address, balance, _token1155Id, s, "2nd Set");
        } else {
            uint balance1155 = IERC1155(_erc1155Address).balanceOf(msg.sender, _token1155Id);
            IERC1155(_erc1155Address).safeTransferFrom(msg.sender, address(this), _token1155Id, balance1155, "");

            Attribute memory newAttribute = Attribute(_erc1155Address, _token1155Id);
            attributes[_token721Id][s] = newAttribute;
            emit SetAttribute(_token721Id, _erc1155Address, balance1155, _token1155Id, s, "1st Set");
        }
    }

    function getAttribute(string calldata s, uint _token721Id) external view returns(address erc1155Address, uint token1155Id) {
        Attribute memory attribute = attributes[_token721Id][s];
        return (attribute.erc1155Address, attribute.erc1155TokenId);
    }
}