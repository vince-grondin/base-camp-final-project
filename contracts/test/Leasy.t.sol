// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/Leasy.sol";

/**
 * @title Verifies the behavior of the Leasy contract.
 * @author Roch
 */
contract LeasyTest is Test {
    Leasy private leasy;

    Leasy.Property private defaultProperty;

    Leasy.Property private propertyFixture1;
    Leasy.Property private propertyFixture2;

    Leasy.Booking private bookingFixture1;

    event BookingRequested(uint propertyID, uint bookingID);
    event PropertyAdded(uint propertyID);
    event PropertyActivated(uint propertyID);

    function setUp() public {
        leasy = new Leasy("TEST_NAME", "TEST_SYMBOL");
        _initializeTestFixtures();
    }

    /**
     * @dev Verifies that calling `addProperty` adds a property.
     * @param _owner The address of the user who added a property.
     * @param _retriever The address of the user getting the properties.
     */
    function test_GivenNoPropertiesAdded_WhenAddingProperty_ThenSuccess(
        address _owner,
        address _retriever
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_retriever != address(0) && _retriever != _owner);

        vm.startPrank(_owner);
        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyAdded(1);

        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result = leasy.getProperties();

        assertEq(result.length, 1);

        Leasy.Property memory expectedProperty1 = propertyFixture1;
        expectedProperty1.owner = _owner;
        _assertEqProperty(result[0], expectedProperty1);
    }

    /**
     * @dev Verifies that calling `addProperty` adds a property.
     * @param _owner1 The address of the user who added a property.
     * @param _owner2 The address of the user who added a property.
     * @param _retriever The address of the user getting the properties.
     */
    function test_GivenPropertyAdded_WhenAddingProperty_ThenSuccess(
        address _owner1,
        address _owner2,
        address _retriever
    ) public {
        vm.assume(_owner1 != address(0));
        vm.assume(_owner2 != address(0) && _owner2 != _owner1);
        vm.assume(
            _retriever != address(0) &&
                _retriever != _owner1 &&
                _retriever != _owner2
        );

        Leasy.Property memory expectedProperty1 = propertyFixture1;
        expectedProperty1.owner = _owner1;

        Leasy.Property memory expectedProperty2 = propertyFixture2;
        expectedProperty2.owner = _owner2;

        vm.startPrank(_owner1);
        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyAdded(1);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result1 = leasy.getProperties();
        vm.stopPrank();

        assertEq(result1.length, 1);
        _assertEqProperty(result1[0], expectedProperty1);

        vm.startPrank(_owner2);
        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyAdded(2);
        _addProperty(propertyFixture2);
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result2 = leasy.getProperties();

        assertEq(result2.length, 2);
        _assertEqProperty(result2[0], expectedProperty1);
        _assertEqProperty(result2[1], expectedProperty2);
    }

    /**
     * @dev Verifies that calling `getProperties` before adding any properties returns an empty array.
     */
    function test_GivenNoPropertiesAdded_WhenGettingProperties_ThenEmptyArrayReturned()
        public
    {
        Leasy.Property[] memory result = leasy.getProperties();

        assertEq(result.length, 0);
    }

    /**
     * @dev Verifies that calling `getProperties` after adding a property return an array with the property.
     * @param _owner The address of the user who added a property.
     * @param _retriever The address of the user getting the properties.
     */
    function test_GivenPropertiesAdded_WhenGettingProperties_ThenPropertiesReturned(
        address _owner,
        address _retriever
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_retriever != address(0) && _retriever != _owner);

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result = leasy.getProperties();

        assertEq(result.length, 1);

        Leasy.Property memory expectedProperty1 = propertyFixture1;
        expectedProperty1.owner = _owner;
        _assertEqProperty(result[0], expectedProperty1);
    }

    /**
     * @dev Verifies that when calling `activateProperty` and that the property does not exist then it reverts with a
     *      `PropertyDoesNotExist` error.
     * @param _owner Owner of the property.
     * @param _propertyID ID of the property.
     * @param _depositAmount Amount of the deposit to pay before the property can be rented.
     */
    function test_GivenPropertiesExist_AndPropertyIDNotExist_WhenActivatingProperty_ThenPropertyDoesNotExistRevert(
        address _owner,
        uint _propertyID,
        uint _depositAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_propertyID != propertyFixture1.id && _propertyID > 1);
        vm.assume(_depositAmount != 0);

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        _expectPropertyDoesNotExistRevert(_propertyID);

        leasy.activateProperty(_propertyID, _depositAmount);
    }

    /**
     * @dev Verifies that when calling `activateProperty` and that the property is not owned by the sender then it
     *      reverts with a `SenderNotOwner` error.
     * @param _owner Owner of the property.
     * @param _otherUser Another user.
     * @param _depositAmount Amount of the deposit to pay before the property can be rented.
     */
    function test_GivenPropertyExist_AndNotOwner_WhenActivatingProperty_ThenSenderNotOwnerRevert(
        address _owner,
        address _otherUser,
        uint _depositAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_otherUser != address(0) && _otherUser != _owner);
        vm.assume(_depositAmount != 0);
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_otherUser);
        vm.expectRevert(
            abi.encodeWithSelector(ILeasy.SenderNotOwner.selector, propertyID)
        );
        leasy.activateProperty(propertyID, _depositAmount);
    }

    /**
     * @dev Verifies that when calling `activateProperty` and that the property owned by the sender it succeeds.
     * @param _owner Owner of the property.
     * @param _depositAmount Amount of the deposit to pay before the property can be rented.
     */
    function test_GivenPropertyExist_AndSenderIsOwner_WhenActivatingProperty_ThenSuccess(
        address _owner,
        uint _depositAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_depositAmount != 0);
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);

        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyActivated(propertyID);

        bool result = leasy.activateProperty(propertyID, _depositAmount);

        assertTrue(result);

        Leasy.Property memory property = leasy.getProperties()[0];
        Leasy.Property memory expectedProperty = propertyFixture1;
        expectedProperty.owner = _owner;
        expectedProperty.status = ILeasy.PropertyStatus.AVAILABLE;
        expectedProperty.depositAmount = _depositAmount;
        _assertEqProperty(property, expectedProperty);
    }

    /**
     * @dev Verifies that calling `requestBooking` with the ID of a property that does not exist reverts with a
     *      `PropertyDoesNotExist` error.
     * @param _owner The owner of the property.
     * @param _booker The user submitting a request to book the property.
     * @param _inexistingPropertyID The ID of a property that does not exist.
     */
    function test_GivenPropertyNotExist_WhenRequestingBooking_ThenPropertyDoesNotExistRevert(
        address _owner,
        address _booker,
        uint _inexistingPropertyID
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_booker != address(0));
        vm.assume(
            _inexistingPropertyID != propertyFixture1.id &&
                _inexistingPropertyID > 1
        );

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        _expectPropertyDoesNotExistRevert(_inexistingPropertyID);

        vm.startPrank(_booker);
        leasy.requestBooking(_inexistingPropertyID, bookingFixture1.dates);
    }

    /**
     * @dev Verifies that calling `requestBooking` with the ID of a property that is not available reverts with a
     *      `PropertyNotAvailable` error.
     * @param _owner The owner of the property.
     * @param _booker The user submitting a request to book the property.
     */
    function test_GivenPropertyExists_AndPropertyInactive_WhenRequestingBooking_ThenPropertyNotAvailableRevert(
        address _owner,
        address _booker
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_booker != address(0));

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        _expectPropertyNotAvailableRevert(propertyFixture1.id);

        leasy.requestBooking(propertyFixture1.id, bookingFixture1.dates);
    }

    /**
     * @dev Verifies that calling `requestBooking` with a call balance lower than the property's required deposit amount
     *      reverts with a `InsufficientDeposit` error.
     * @param _owner The owner of the property.
     * @param _booker The user submitting a request to book the property.
     * @param _bookerBalance The balance of the user submitting a request to book the property.
     * @param _requiredDepositAmount The required deposit amount set for the property.
     * @param _callAmount The amount sent with the `requestBooking` call.
     */
    function test_GivenPropertyExists_AndActive_AndCallAmountLowerThanRequiredPropertyDeposit_WhenRequestingBooking_ThenInsufficientDepositRevert(
        address _owner,
        address _booker,
        uint _bookerBalance,
        uint _requiredDepositAmount,
        uint _callAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_booker != address(0));
        uint bookerBalance = 1000;
        vm.assume(_requiredDepositAmount > 0 && _requiredDepositAmount < 1000);
        vm.assume(_bookerBalance > _requiredDepositAmount);
        vm.assume(_callAmount > 0 && _callAmount < _requiredDepositAmount);

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        leasy.activateProperty(propertyFixture1.id, _requiredDepositAmount);
        vm.stopPrank();

        _expectInsufficientDepositRevert(propertyFixture1.id, _callAmount);

        vm.deal(_booker, bookerBalance * 1 wei);
        vm.startPrank(_booker);
        leasy.requestBooking{value: _callAmount}(
            propertyFixture1.id,
            bookingFixture1.dates
        );
    }

    /**
     * @dev Verifies that calling `requestBooking` with a call value that is greater or equal than the property's
     *      required deposit amount for a property that exists and that is active succeeds.
     * @param _owner The owner of the property.
     * @param _booker The user submitting a request to book the property.
     * @param _bookerBalance The balance of the user submitting a request to book the property.
     * @param _requiredDepositAmount The required deposit amount set for the property.
     * @param _callAmount The amount sent with the `requestBooking` call.
     */
    function test_GivenPropertyExists_AndActive_AndCallAmountEqualOrGreaterThanRequiredPropertyDeposit_WhenRequestingBooking_ThenSuccess(
        address _owner,
        address _booker,
        uint _bookerBalance,
        uint _requiredDepositAmount,
        uint _callAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_booker != address(0));
        vm.assume(_requiredDepositAmount > 0 && _requiredDepositAmount < 1000);
        vm.assume(_bookerBalance > _requiredDepositAmount);
        vm.assume(
            _callAmount >= _requiredDepositAmount &&
                _callAmount < _bookerBalance
        );

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        leasy.activateProperty(propertyFixture1.id, _requiredDepositAmount);
        vm.stopPrank();

        vm.deal(_booker, _bookerBalance * 1 wei);
        vm.startPrank(_booker);

        vm.expectEmit(true, true, true, true, address(leasy));
        emit BookingRequested(propertyFixture1.id, 1);

        bool result = leasy.requestBooking{value: _callAmount}(
            propertyFixture1.id,
            bookingFixture1.dates
        );

        assertTrue(result);
    }

    /**
     * @dev Verifies that calling `getProperty` when the property does not exist reverts with a `PropertyDoesNotExist`
     *      error
     * @param _owner The address of the user who added a property.
     * @param _retriever The address of the user getting an inexisting property.
     */
    function test_GivenPropertyNotExist_WhenGettingProperty_ThenPropertyDoesNotExistRevert(
        address _owner,
        address _retriever,
        uint _inexistingPropertyID
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_retriever != address(0) && _retriever != _owner);
        vm.assume(
            _inexistingPropertyID > 0 &&
                _inexistingPropertyID != propertyFixture1.id
        );

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_retriever);

        _expectPropertyDoesNotExistRevert(_inexistingPropertyID);

        leasy.getProperty(_inexistingPropertyID);
    }

    /**
     * @dev Verifies that calling `getProperty` for a property that exists succeeds.
     * @param _owner The address of the user who added a property.
     * @param _retriever The address of the user getting an inexisting property.
     */
    function test_GivenPropertyExists_WhenGettingProperty_ThenSuccess(
        address _owner,
        address _retriever
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_retriever != address(0) && _retriever != _owner);

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_retriever);

        ILeasy.Property memory result = leasy.getProperty(propertyFixture1.id);

        ILeasy.Property memory expectedProperty = propertyFixture1;
        expectedProperty.owner = _owner;
        _assertEqProperty(result, expectedProperty);
    }

    /**
     * @dev Helper function that delegates to `leasy#addProperty`.
     * @param _property The property to add.
     */
    function _addProperty(Leasy.Property memory _property) private {
        leasy.addProperty(
            _property.name,
            _property.fullAddress,
            _property.picturesUrls
        );
    }

    /**
     * @dev Asserts that `_actual` property equals `_expected` property.
     * @param _actual The property to assert.
     * @param _expected The property to assert the `_actual` property against.
     */
    function _assertEqProperty(
        Leasy.Property memory _actual,
        Leasy.Property memory _expected
    ) private {
        assertEq(
            keccak256(abi.encode(_actual)),
            keccak256(abi.encode(_expected))
        );
    }

    function _assumeDistinctRenters(
        address _owner,
        address _renter1,
        address _renter2,
        address _renter3
    ) private pure {
        vm.assume(_renter1 != _owner && _renter1 != address(0));
        vm.assume(
            _renter2 != _owner && _renter2 != address(0) && _renter2 != _renter1
        );
        vm.assume(
            _renter3 != _owner &&
                _renter3 != address(0) &&
                _renter3 != _renter2 &&
                _renter3 != _renter1
        );
    }

    /**
     * @dev Verifies that a `InsufficientDeposit` occurs.
     * @param _propertyID The ID of the property.
     * @param _msgValue The value sent with the call (msg.value).
     */
    function _expectInsufficientDepositRevert(
        uint _propertyID,
        uint _msgValue
    ) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                ILeasy.InsufficientDeposit.selector,
                _propertyID,
                _msgValue
            )
        );
    }

    /**
     * @dev Verifies that a `PropertyDoesNotExist` occurs.
     * @param _inexistingPropertyID The ID of the property that does not exist.
     */
    function _expectPropertyDoesNotExistRevert(
        uint _inexistingPropertyID
    ) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                ILeasy.PropertyDoesNotExist.selector,
                _inexistingPropertyID
            )
        );
    }

    /**
     * @dev Verifies that a `PropertyNotAvailable` occurs.
     * @param _notAvailablePropertyID The ID of the property that is inactive.
     */
    function _expectPropertyNotAvailableRevert(
        uint _notAvailablePropertyID
    ) private {
        vm.expectRevert(
            abi.encodeWithSelector(
                ILeasy.PropertyNotAvailable.selector,
                _notAvailablePropertyID
            )
        );
    }

    /**
     * @dev Initializes the test fixtures.
     */
    function _initializeTestFixtures() private {
        propertyFixture1.id = 1;
        propertyFixture1.name = "Tiny House";
        propertyFixture1.fullAddress = "123 Fake Street";
        propertyFixture1.picturesUrls = "https://bitcoin.org/bitcoin.pdf";
        propertyFixture1.status = ILeasy.PropertyStatus.INACTIVE;
        propertyFixture1.owner = address(1);

        propertyFixture2.id = 2;
        propertyFixture2.name = "Small House";
        propertyFixture2.fullAddress = "456 Fake Street";
        propertyFixture2.picturesUrls = "https://etherscan.io";
        propertyFixture2.status = ILeasy.PropertyStatus.INACTIVE;
        propertyFixture1.owner = address(2);

        bookingFixture1.id = 1;
        bookingFixture1.propertyID = propertyFixture1.id;
        bookingFixture1.depositAmount = 1000;
        bookingFixture1.dates = new string[](2);
        bookingFixture1.dates[0] = "1/5/24";
        bookingFixture1.dates[1] = "1/6/24";
        bookingFixture1.status = ILeasy.BookingStatus.REQUESTED;
    }

    /**
     * @dev Initializes an array of renters.
     * @param _renter1 The address of a renter.
     * @param _renter2 The address of another renter.
     * @param _renter3 The address of another renter.
     */
    function _initializeRenters(
        address _renter1,
        address _renter2,
        address _renter3
    ) private pure returns (address[] memory renters) {
        renters = new address[](3);
        renters[0] = _renter1;
        renters[1] = _renter2;
        renters[2] = _renter3;
    }
}
