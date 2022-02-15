// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @notice Access Controls contract for Test ERC721 contract
 */
contract TestAccessControl is AccessControl {
    /// @notice Role definitions
    bytes32 public constant ATTRIBUTE_MANAGER_ROLE = 
    0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6; // keccak256("ATTRIBUTE_MANAGER_ROLE")

    /// @notice Events for adding and removing various roles
    event AttributeManagerRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event AttributeManagerRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    /**
     * @notice The deployer is automatically given the admin role which will allow them to then grant roles to other addresses
     */
    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    /////////////
    // Lookups //
    /////////////

    /**
     * @notice Used to check whether an address has the admin role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    /**
     * @notice Used to check whether an address has the minter role
     * @param _address EOA or contract being checked
     * @return bool True if the account has the role or false if it does not
     */
    function hasAttributeManagerRole(address _address) external view returns (bool) {
        return hasRole(ATTRIBUTE_MANAGER_ROLE, _address);
    }

    ///////////////
    // Modifiers //
    ///////////////

    /**
     * @notice Grants the minter role to an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract receiving the new role
     */
    function addAttributeManagerRole(address _address) external {
        grantRole(ATTRIBUTE_MANAGER_ROLE, _address);
        emit AttributeManagerRoleGranted(_address, _msgSender());
    }

    /**
     * @notice Removes the minter role from an address
     * @dev The sender must have the admin role
     * @param _address EOA or contract affected
     */
    function removeAttributeManagerRole(address _address) external {
        revokeRole(ATTRIBUTE_MANAGER_ROLE, _address);
        emit AttributeManagerRoleRemoved(_address, _msgSender());
    }
}