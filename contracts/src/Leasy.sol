// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
interface ILeasy is IERC721 {
    enum PropertyStatus {
        AVAILABLE, // Default value, keep this first
        PROCESSING,
        RENTING
    }

    enum SignatureStatus {
        PENDING, // Default value, keep this first
        APPROVED,
        DECLINED
    }

    error PropertyDoesNotExist(uint propertyID);
    error PropertyNotAvailable(uint propertyID);
    error SenderNotOwner(uint propertyID);

    event PropertyAdded(uint propertyID);
    event PropertyLeasingInitiated(uint propertyID);

    struct Property {
        uint id;
        string name;
        string fullAddress;
        address owner;
        string leaseAgreementUrl;
        PropertyStatus status;
        uint depositAmount;
        address[] renters;
        SignatureStatus[] signatureStatuses;
    }

    /**
     * @notice Adds a property.
     * @param _name The name of the property.
     * @param _fullAddress The full address of the property.
     * @param _leaseAgreementUrl The URL to the lease agreement.
     */
    function addProperty(
        string memory _name,
        string memory _fullAddress,
        string memory _leaseAgreementUrl
    ) external returns (uint propertyID);

    /**
     * @notice Gets all properties.
     * @return All properties.
     */
    function getProperties() external returns (Property[] memory);

    /**
     * @notice Initiates the leasing process by setting a deposit amount, an array of potential renters and the date
     *         the lease ends.
     * @param _propertyID The ID of the property.
     * @param _renters The addresses of the potential renters.
     * @param _depositAmount The requested deposted amount.
     */
    function leaseProperty(
        uint _propertyID,
        address[] memory _renters,
        uint _depositAmount
    ) external returns (bool);
}

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
contract Leasy is ILeasy, ERC721 {
    using PropertySignatureStatuses for ILeasy.Property;

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

    /// @inheritdoc ILeasy
    function leaseProperty(
        uint _propertyID,
        address[] memory _renters,
        uint _depositAmount
    )
        external
        override
        propertyExists(_propertyID)
        propertyAvailable(_propertyID)
        isOwner(_propertyID)
        returns (bool)
    {
        Property storage property = properties[_propertyID];
        property.status = PropertyStatus.PROCESSING;
        property.depositAmount = _depositAmount;
        property.renters = _renters;
        property._initializeSignatureStatuses();
        
        emit PropertyLeasingInitiated(_propertyID);

        return true;
    }

    /**
     * @dev Checks that the property identified by `_propertyID` is in the `properties` array.
     */
    modifier propertyExists(uint _propertyID) {
        if (_propertyID >= properties.length || properties[_propertyID].id == 0)
            revert PropertyDoesNotExist(_propertyID);
        _;
    }

    /**
     * Checks that the property identified by `_propertyID` has the `PropertyStatus.AVAILABLE` `status`.
     */
    modifier propertyAvailable(uint _propertyID) {
        if (properties[_propertyID].status != PropertyStatus.AVAILABLE)
            revert PropertyNotAvailable(_propertyID);
        _;
    }

    /**
     * Checks that the sender owns the property identified by `_propertyID.
     */
    modifier isOwner(uint _propertyID) {
        if (_msgSender() != _ownerOf(_propertyID))
            revert SenderNotOwner(_propertyID);
        _;
    }
}

/**
 * @title Managers property signature statuses
 * @author Roch
 */
library PropertySignatureStatuses {
    /**
     * @dev Initializes the signature statuses of the `_property` property.
     * @param _property The property for which to initialize signature statuses.
     */
    function _initializeSignatureStatuses(
        ILeasy.Property storage _property
    ) internal {
        for (uint i = 0; i < _property.renters.length; i++) {
            _property.signatureStatuses.push();
        }
    }
}
