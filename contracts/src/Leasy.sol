// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
interface ILeasy is IERC721 {
    struct Property {
        uint id;
        string name;
        string fullAddress;
        address owner;
        string leaseAgreementUrl;
        address[] signers;
        SignerStatus[] signersStatuses;
    }

    enum SignerStatus {
        APPROVED,
        DECLINED,
        PENDING
    }

    event PropertyAdded(uint propertyID);

    /**
     * @notice Adds a property.
     * @param _name The name of the property.
     * @param _fullAddress The full address of the property.
     * @param leaseAgreementUrl The URL to the lease agreement.
     */
    function addProperty(
        string memory _name,
        string memory _fullAddress,
        string memory leaseAgreementUrl
    ) external returns (uint propertyID);

    /**
     * @notice Gets all properties.
     * @return All properties.
     */
    function getProperties() external returns (Property[] memory);
}

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
contract Leasy is ILeasy, ERC721 {
    Property[] internal properties;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        properties.push();
    }

    /// @inheritdoc ILeasy
    function addProperty(
        string memory _name,
        string memory _fullAddress,
        string memory _leaseAgreementUrl
    ) external override returns (uint propertyID) {
        propertyID = properties.length;
        _mint(_msgSender(), propertyID);

        Property storage property = properties.push();
        property.id = propertyID;
        property.name = _name;
        property.fullAddress = _fullAddress;
        property.leaseAgreementUrl = _leaseAgreementUrl;
        property.owner = _msgSender();

        emit PropertyAdded(propertyID);
    }

    /// @inheritdoc ILeasy
    function getProperties()
        external
        view
        override
        returns (Property[] memory)
    {
        return properties;
    }
}
