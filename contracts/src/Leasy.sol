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
        DEFAULT,
        PENDING,
        APPROVED,
        DECLINED
    }

    error PropertyDoesNotExist(uint propertyID);
    error PropertyNotAvailable(uint propertyID);
    error PropertyNotProcessing(uint propertyID);
    error SenderNotOwner(uint propertyID);
    error SenderNotRenter(uint propertyID);

    event PropertyAdded(uint propertyID);
    event PropertyLeasingInitiated(uint propertyID);
    event PropertyLeaseSignatureSaved(
        uint propertyID,
        address userID,
        SignatureStatus signatureStatus
    );

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

    /**
     * @notice Submits a decision for the sender for a property for which the leasing process was initiated.
     * @param _propertyID The ID of the property.
     */
    function signLease(
        uint _propertyID,
        SignatureStatus signatureStatus
    ) external returns (bool);
}

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
contract Leasy is ILeasy, ERC721 {
    using PropertyInitializers for Leasy.InternalProperty;

    struct InternalProperty {
        uint id;
        string name;
        string fullAddress;
        address owner;
        string leaseAgreementUrl;
        PropertyStatus status;
        uint depositAmount;
    }

    InternalProperty[] internal properties;

    mapping(uint propertyID => address[] renters) internal renters;
    mapping(uint propertyID => mapping(address renter => uint renterIndex))
        internal renterIndexes;
    mapping(uint propertyID => mapping(address renter => bool isActive))
        internal activeRenters;

    mapping(uint propertyID => SignatureStatus[] signatureStatus)
        internal signatureStatuses;

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

        InternalProperty storage property = properties.push();
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
        returns (Property[] memory externalProperties)
    {
        externalProperties = new Property[](properties.length - 1);

        for (uint i = 0; i < externalProperties.length; i++) {
            InternalProperty storage property = properties[i + 1];
            externalProperties[i] = Property({
                id: property.id,
                name: property.name,
                fullAddress: property.fullAddress,
                owner: property.owner,
                leaseAgreementUrl: property.leaseAgreementUrl,
                status: property.status,
                depositAmount: property.depositAmount,
                renters: renters[property.id],
                signatureStatuses: signatureStatuses[property.id]
            });
        }
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
        InternalProperty storage property = properties[_propertyID];
        property.status = PropertyStatus.PROCESSING;
        property.depositAmount = _depositAmount;
        property._initializeRenters(
            _renters,
            renters,
            renterIndexes,
            activeRenters
        );
        property._initializeSignatureStatuses(
            _renters.length,
            signatureStatuses
        );

        emit PropertyLeasingInitiated(_propertyID);

        return true;
    }

    /// @inheritdoc ILeasy
    function signLease(
        uint _propertyID,
        SignatureStatus signatureStatus
    )
        external
        override
        propertyExists(_propertyID)
        propertyProcessing(_propertyID)
        isRenter(_propertyID)
        returns (bool)
    {
        uint renterIndex = renterIndexes[_propertyID][_msgSender()];
        signatureStatuses[_propertyID][renterIndex] = signatureStatus;
        emit PropertyLeaseSignatureSaved(
            _propertyID,
            _msgSender(),
            signatureStatus
        );
        return true;
    }

    /**
     * @dev Checks that the sender owns the property identified by `_propertyID`.
     * @param _propertyID The ID of the property.
     */
    modifier isOwner(uint _propertyID) {
        if (_msgSender() != _ownerOf(_propertyID))
            revert SenderNotOwner(_propertyID);
        _;
    }

    /**
     * @dev Checks that the sender is one of the designated renters of the property identified by `_propertyID`.
     * @param _propertyID The ID of the property.
     */
    modifier isRenter(uint _propertyID) {
        if (!activeRenters[_propertyID][_msgSender()])
            revert SenderNotRenter(_propertyID);
        _;
    }

    /**
     * @dev Checks that the property identified by `_propertyID` has the `PropertyStatus.AVAILABLE` `status`.
     * @param _propertyID The ID of the property.
     */
    modifier propertyAvailable(uint _propertyID) {
        if (properties[_propertyID].status != PropertyStatus.AVAILABLE)
            revert PropertyNotAvailable(_propertyID);
        _;
    }

    /**
     * @dev Checks that the property identified by `_propertyID` is in the `properties` array.
     * @param _propertyID The ID of the property.
     */
    modifier propertyExists(uint _propertyID) {
        if (_propertyID >= properties.length || properties[_propertyID].id == 0)
            revert PropertyDoesNotExist(_propertyID);
        _;
    }

    /**
     * @dev Checks that the property identified by `_propertyID` has the `PropertyStatus.AVAILABLE` `status`.
     * @param _propertyID The ID of the property.
     */
    modifier propertyProcessing(uint _propertyID) {
        if (properties[_propertyID].status != PropertyStatus.PROCESSING)
            revert PropertyNotProcessing(_propertyID);
        _;
    }
}

/**
 * @title Managers initialization of variables related to `Property`.
 * @author Roch
 */
library PropertyInitializers {
    /**
     * @dev Initializes the renters of a `Property` and the renter index by property by renter mapping.
     * @param _property The property for which to initialize the renters.
     * @param _newRenters The addresses of the potential renters.
     * @param _renters The mapping of renters by property ID.
     * @param _renterIndexes The mapping of renter index by renter by property ID.
     * @param _activeRenters The mapping of whether a renter is active by renter by property ID.
     */
    function _initializeRenters(
        Leasy.InternalProperty storage _property,
        address[] memory _newRenters,
        mapping(uint propertyID => address[] renters) storage _renters,
        mapping(uint propertyID => mapping(address renter => uint renterIndex))
            storage _renterIndexes,
        mapping(uint propertyID => mapping(address renter => bool isActive))
            storage _activeRenters
    ) internal {
        _renters[_property.id] = _newRenters;

        for (uint i = 0; i < _newRenters.length; i++) {
            _renterIndexes[_property.id][_newRenters[i]] = i;
            _activeRenters[_property.id][_newRenters[i]] = true;
        }
    }

    /**
     * @dev Initializes the signature statuses of the `_property` property.
     * @param _property The property for which to initialize the signature statuses.
     * @param _count The number of signature statuses to initialize.
     * @param signatureStatuses The mapping of signature status by property ID by renter.
     */
    function _initializeSignatureStatuses(
        Leasy.InternalProperty storage _property,
        uint _count,
        mapping(uint propertyID => ILeasy.SignatureStatus[] signatureStatus)
            storage signatureStatuses
    ) internal {
        for (uint i = 0; i < _count; i++) {
            signatureStatuses[_property.id].push(
                ILeasy.SignatureStatus.PENDING
            );
        }
    }
}
