// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
interface ILeasy is IERC721 {
    enum PropertyStatus {
        INACTIVE, // Default, keep first
        AVAILABLE
    }

    error DuplicateApplicant(uint propertyID, address applicant);
    error InsufficientDeposit(uint propertyID, uint submittedAmount);
    error PropertyDoesNotExist(uint propertyID);
    error PropertyNotAssigned(uint propertyID);
    error PropertyNotAvailable(uint propertyID);
    error PropertyNotInactive(uint propertyID);
    error SenderIsOwner(uint propertyID);
    error SenderNotOwner(uint propertyID);
    error SenderNotRenter(uint propertyID);

    event PropertyAdded(uint propertyID);
    event PropertyActivated(uint propertyID);

    struct Property {
        uint id;
        string name;
        string fullAddress;
        address owner;
        string picturesUrls;
        PropertyStatus status;
        uint depositAmount;
        address[] applicants;
        string[] applicantsDates;
        address[] renters;
        string[] rentersDates;
    }

    /**
     * @notice Adds a property.
     * @param _name The name of the property.
     * @param _fullAddress The full address of the property.
     * @param _picturesUrls The comma-separated string of URLs pictures of the property.
     */
    function addProperty(
        string memory _name,
        string memory _fullAddress,
        string memory _picturesUrls
    ) external returns (uint propertyID);

    /**
     * @notice Activates the property identified by the supplied `_propertyID` by making it available and
     *          defining a deposit amount.
     * @param _propertyID The ID of the property.
     * @param _depositAmount The requested deposted amount.
     */
    function activateProperty(
        uint _propertyID,
        uint _depositAmount
    ) external returns (bool);

    /**
     * @notice Inquires for a stay at the property identified by the supplied `_propertyID`.
     * @param _propertyID The ID of the property.
     * @param _dates Comma-separated list of dates the sender is interested in staying at the property.
     */
    function inquireStay(
        uint _propertyID,
        string memory _dates
    ) external payable returns (bool);

    /**
     * @notice Assigns an applicant as a renter of the property identified by the supplied `_propertyID` for the
     *         specified dates.
     * @param _propertyID The ID of the property.
     * @param _applicant The applicant to designate as a renter.
     * @param _dates The dates the applicant being designated as a renter will rent the property.
     */
    function selectApplicant(
        uint _propertyID,
        address _applicant,
        string memory _dates
    ) external returns (bool);

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
    struct InternalProperty {
        uint id;
        string name;
        string fullAddress;
        address owner;
        string picturesUrls;
        PropertyStatus status;
        uint depositAmount;
    }

    InternalProperty[] internal properties;

    mapping(uint propertyID => address[] renters) internal renters;
    mapping(uint propertyID => string[] dates) internal rentersDates;

    mapping(uint propertyID => address[] applicants) internal applicants;
    mapping(uint propertyID => mapping(address applicant => uint applicantIndex))
        internal applicantsIndexes;
    mapping(uint propertyID => mapping(address applicant => uint depositAmount))
        internal applicantsDeposits;
    mapping(uint propertyID => uint count) internal applicantsCount;

    mapping(uint propertyID => string[] dates) internal applicantsDates;

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
        string memory _picturesUrls
    ) external override returns (uint propertyID) {
        propertyID = properties.length;
        _mint(_msgSender(), propertyID);

        InternalProperty storage property = properties.push();
        property.id = propertyID;
        property.name = _name;
        property.fullAddress = _fullAddress;
        property.picturesUrls = _picturesUrls;
        property.owner = _msgSender();

        emit PropertyAdded(propertyID);
    }

    /// @inheritdoc ILeasy
    function activateProperty(
        uint _propertyID,
        uint _depositAmount
    )
        external
        override
        propertyExists(_propertyID)
        propertyInactive(_propertyID)
        isOwner(_propertyID)
        returns (bool)
    {
        InternalProperty storage property = properties[_propertyID];
        property.status = PropertyStatus.AVAILABLE;
        property.depositAmount = _depositAmount;

        emit PropertyActivated(_propertyID);

        return true;
    }

    /// @inheritdoc ILeasy
    function inquireStay(
        uint _propertyID,
        string memory _dates
    )
        external
        payable
        override
        propertyExists(_propertyID)
        propertyAvailable(_propertyID)
        returns (bool)
    {
        if (msg.value < properties[_propertyID].depositAmount)
            revert InsufficientDeposit(_propertyID, msg.value);

        // TODO Check dates not already booked (not already in rentersDates)

        applicantsIndexes[_propertyID][_msgSender()] = applicants[_propertyID]
            .length;
        applicants[_propertyID].push(_msgSender());
        applicantsDates[_propertyID].push(_dates);
        applicantsDeposits[_propertyID][_msgSender()] += msg.value;
        applicantsCount[_propertyID]++;
        return true;
    }

    /**
     * @inheritdoc ILeasy
     * @dev Transfers the `_applicant` address from `applicants` to `renters`.
     */
    function selectApplicant(
        uint _propertyID,
        address _applicant,
        string memory _dates
    )
        external
        override
        propertyExists(_propertyID)
        propertyAvailable(_propertyID)
        isOwner(_propertyID)
        returns (bool)
    {
        renters[_propertyID].push(_applicant);
        rentersDates[_propertyID].push(_dates);

        uint applicantIndex = applicantsIndexes[_propertyID][_applicant];
        delete applicants[_propertyID][applicantIndex];
        delete applicantsDates[_propertyID][applicantIndex];
        applicantsCount[_propertyID]--;

        // TODO Return deposit of applicants that selected any dates the same as any of this selected applicant's dates

        return true;
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
            uint propertyID = property.id;
            uint propertyApplicantsCount = applicantsCount[propertyID];

            address[] memory _applicants = new address[](
                propertyApplicantsCount
            );
            string[] memory _applicantsDates = new string[](
                propertyApplicantsCount
            );
            uint activeApplicantsCursor = 0;
            for (uint j = 0; j < applicants[propertyID].length; j++) {
                address applicant = applicants[propertyID][j];

                if (applicant == address(0)) continue;

                _applicants[activeApplicantsCursor] = applicant;

                _applicantsDates[activeApplicantsCursor] = applicantsDates[
                    propertyID
                ][j];

                activeApplicantsCursor++;
            }

            externalProperties[i] = Property({
                id: propertyID,
                name: property.name,
                fullAddress: property.fullAddress,
                owner: property.owner,
                picturesUrls: property.picturesUrls,
                status: property.status,
                depositAmount: property.depositAmount,
                applicants: _applicants,
                applicantsDates: _applicantsDates,
                renters: renters[propertyID],
                rentersDates: rentersDates[propertyID]
            });
        }
    }

    /**
     * @dev Checks that the sender is not the owner of the property identified by `_propertyID`.
     * @param _propertyID The ID of the property.
     */
    modifier isNotOwner(uint _propertyID) {
        if (_msgSender() == _ownerOf(_propertyID))
            revert SenderIsOwner(_propertyID);
        _;
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
     * @dev Checks that the property identified by `_propertyID` has the `PropertyStatus.INACTIVE` `status`.
     * @param _propertyID The ID of the property.
     */
    modifier propertyInactive(uint _propertyID) {
        if (properties[_propertyID].status != PropertyStatus.INACTIVE)
            revert PropertyNotInactive(_propertyID);
        _;
    }
}
