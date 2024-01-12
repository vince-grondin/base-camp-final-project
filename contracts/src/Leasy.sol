// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./LeasyStay.sol";

/**
 * @title Main contract hosting logic for Leasy, a system allowing to mint properties and lease them.
 * @author Roch
 */
interface ILeasy is IERC721 {
    enum BookingStatus {
        REQUESTED, // Default, keep first
        ACCEPTED,
        ENDED
    }

    enum PropertyStatus {
        INACTIVE, // Default, keep first
        AVAILABLE
    }

    error BookingDoesNotExist(uint bookingID);

    error InsufficientDeposit(uint propertyID, uint submittedAmount);
    error PropertyDoesNotExist(uint propertyID);
    error PropertyNotAvailable(uint propertyID);
    error PropertyNotInactive(uint propertyID);
    error SenderIsOwner(uint propertyID);
    error SenderNotOwner(uint propertyID);
    error SenderNotRenter(uint propertyID);

    event BookingRequested(uint propertyID, uint bookingID);
    event BookingEnded(uint propertyID, uint bookingID);
    event PropertyAdded(uint propertyID);
    event PropertyActivated(uint propertyID);

    struct Booking {
        uint id;
        address booker;
        uint propertyID;
        uint depositAmount;
        string[] dates;
        BookingStatus status;
    }

    struct Property {
        uint id;
        string name;
        string fullAddress;
        address owner;
        string picturesUrls;
        PropertyStatus status;
        uint depositAmount;
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
     * @notice Request a booking at the property identified by the supplied `_propertyID`.
     * @param _propertyID The ID of the property.
     * @param _dates The list of dates the sender is interested in staying at the property.
     */
    function requestBooking(
        uint _propertyID,
        string[] memory _dates
    ) external payable returns (bool);

    /**
     * @notice Accepts a booking.
     * @param _bookingID The ID of the booking.
     */
    function acceptBooking(uint _bookingID) external returns (bool);

    /**
     * @notice Ends a booking and rewards the booking with a `LeasyStay` NFT.
     * @dev Updates the booking status to COMPLETED and invokes the `LeasyStay` contract to mint a LeasyStay for the
     *      booker.
     * @param _bookingID The ID of the booking.
     */
    function endBooking(uint _bookingID) external returns (bool);

    /**
     * @notice Gets the bookings submitted for the property identified by the supplied `_propertyID`.
     * @param _propertyID The ID of the property.
     * @return propertyBookings The bookings submitted for the property identified by the supplied `_propertyID`.
     */
    function getBookings(
        uint _propertyID
    ) external returns (Booking[] memory propertyBookings);

    /**
     * @notice Gets the property identified by the supplied `_propertyID`.
     * @param _propertyID The ID of the property.
     */
    function getProperty(
        uint _propertyID
    ) external view returns (Property memory);

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
    mapping(uint propertyID => uint propertyIndex) internal propertyIndexes;

    Booking[] internal bookings;
    mapping(uint bookingID => uint bookingIndex) internal bookingsIndexes;
    mapping(uint propertyID => uint[] bookingIDs) propertyBookingIDs;

    LeasyStay leasyStay;

    constructor(
        string memory _name,
        string memory _symbol,
        address _leasyStay
    ) ERC721(_name, _symbol) {
        // Avoid 0 index
        properties.push();
        bookings.push();
        leasyStay = LeasyStay(_leasyStay);
    }

    /// @inheritdoc ILeasy
    function addProperty(
        string memory _name,
        string memory _fullAddress,
        string memory _picturesUrls
    ) external override returns (uint propertyID) {
        // TODO Support status param to activate when adding, support deposit amount to set deposit when adding
        propertyID = properties.length;
        uint propertyIndex = properties.length;

        _mint(_msgSender(), propertyID);

        Property storage property = properties.push();
        property.id = propertyID;
        property.name = _name;
        property.fullAddress = _fullAddress;
        property.picturesUrls = _picturesUrls;
        property.owner = _msgSender();

        propertyIndexes[propertyID] = propertyIndex;

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
        Property storage property = properties[_propertyID];
        property.status = PropertyStatus.AVAILABLE;
        property.depositAmount = _depositAmount;

        emit PropertyActivated(_propertyID);

        return true;
    }

    /// @inheritdoc ILeasy
    function requestBooking(
        uint _propertyID,
        string[] memory _dates
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

        // TODO Check dates not already booked for this property

        uint bookingID = bookings.length;
        uint bookingIndex = bookings.length;
        bookings.push(
            Booking({
                id: bookingID,
                booker: _msgSender(),
                propertyID: _propertyID,
                depositAmount: msg.value,
                dates: _dates,
                status: BookingStatus.REQUESTED
            })
        );

        bookingsIndexes[bookingID] = bookingIndex;

        propertyBookingIDs[_propertyID].push(bookingID);

        emit BookingRequested(_propertyID, bookingID);

        return true;
    }

    /// @inheritdoc ILeasy
    function acceptBooking(
        uint _bookingID
    )
        external
        override
        bookingExists(_bookingID)
        isOwnerByBookingID(_bookingID)
        returns (bool)
    {
        // TODO Check dates not already booked for this property
        bookings[bookingsIndexes[_bookingID]].status = BookingStatus.ACCEPTED;

        // TODO Return deposit of applicants that selected any dates the same as any of this selected applicant's dates

        return true;
    }

    /// @inheritdoc ILeasy
    function endBooking(
        uint _bookingID
    )
        external
        override
        bookingExists(_bookingID)
        isOwnerByBookingID(_bookingID)
        returns (bool)
    {
        Booking memory booking = bookings[bookingsIndexes[_bookingID]];
        booking.status = BookingStatus.COMPLETED;

        leasyStay.saveStay(_bookingID, booking.booker, booking.propertyID, booking.dates);

        emit BookingEnded(booking.propertyID, _bookingID);

        return true;
    }

    /// @inheritdoc ILeasy
    function getBookings(
        uint _propertyID
    )
        external
        view
        override
        propertyExists(_propertyID)
        returns (Booking[] memory propertyBookings)
    {
        uint[] memory bookingIDs = propertyBookingIDs[_propertyID];
        propertyBookings = new Booking[](bookingIDs.length);

        for (uint i = 0; i < bookingIDs.length; i++) {
            propertyBookings[i] = bookings[bookingsIndexes[bookingIDs[i]]];
        }
    }

    /// @inheritdoc ILeasy
    function getProperty(
        uint _propertyID
    )
        external
        view
        override
        propertyExists(_propertyID)
        returns (Property memory)
    {
        return properties[propertyIndexes[_propertyID]];
    }

    /// @inheritdoc ILeasy
    function getProperties()
        external
        view
        override
        returns (Property[] memory externalProperties)
    {
        externalProperties = new Property[](properties.length - 1);
        uint cursor = 0;

        for (uint i = 0; i < properties.length; i++) {
            if (i == 0) continue;
            externalProperties[cursor++] = properties[i];
        }
    }

    /**
     * @dev Checks that the booking identified by `_bookingID` is in the `bookings` array.
     * @param _bookingID The ID of the booking.
     */
    modifier bookingExists(uint _bookingID) {
        if (_bookingID >= bookings.length || bookings[_bookingID].id == 0)
            revert BookingDoesNotExist(_bookingID);
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
     * @dev Checks that the sender owns the property identified by `_propertyID`.
     * @param _bookingID The ID of the property.
     */
    modifier isOwnerByBookingID(uint _bookingID) {
        uint propertyID = bookings[bookingsIndexes[_bookingID]].propertyID;
        if (_msgSender() != _ownerOf(propertyID))
            revert SenderNotOwner(propertyID);
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
