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

    event PropertyAdded(uint propertyID);
    event PropertyLeasingInitiated(uint propertyID);
    event PropertyLeaseSignatureSaved(
        uint propertyID,
        address userID,
        ILeasy.SignatureStatus signatureStatus
    );

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
     * @dev Verifies that when calling `leaseProperty` and that the property does not exist then it reverts with a
     *      `PropertyDoesNotExist` error.
     * @param _owner Owner of the property.
     * @param _propertyID ID of the property.
     * @param _renter1 Address of a renter.
     * @param _renter2 Address of another renter.
     * @param _renter3 Address of another renter.
     * @param _depositAmount Amount of the deposit to pay before the property can be rented.
     */
    function test_GivenPropertiesExist_AndPropertyIDNotExist_WhenLeasingProperty_ThenPropertyDoesNotExistRevert(
        address _owner,
        uint _propertyID,
        address _renter1,
        address _renter2,
        address _renter3,
        uint _depositAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_propertyID != propertyFixture1.id && _propertyID > 1);
        vm.assume(_depositAmount != 0);
        _assumeDistinctRenters(_owner, _renter1, _renter2, _renter3);
        address[] memory renters = _initializeRenters(
            _renter1,
            _renter2,
            _renter3
        );

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.expectRevert(
            abi.encodeWithSelector(
                ILeasy.PropertyDoesNotExist.selector,
                _propertyID
            )
        );

        leasy.leaseProperty(_propertyID, renters, _depositAmount);
    }

    /**
     * @dev Verifies that when calling `leaseProperty` and that the property is not owned by the sender then it reverts
     *      with a `SenderNotOwner` error.
     * @param _owner Owner of the property.
     * @param _renter1 Address of a renter.
     * @param _renter2 Address of another renter.
     * @param _renter3 Address of another renter.
     * @param _depositAmount Amount of the deposit to pay before the property can be rented.
     */
    function test_GivenPropertyExist_AndNotOwner_WhenLeasingProperty_ThenSenderNotOwnerRevert(
        address _owner,
        address _renter1,
        address _renter2,
        address _renter3,
        uint _depositAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_depositAmount != 0);
        _assumeDistinctRenters(_owner, _renter1, _renter2, _renter3);
        address[] memory renters = _initializeRenters(
            _renter1,
            _renter2,
            _renter3
        );
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_renter1);
        vm.expectRevert(
            abi.encodeWithSelector(ILeasy.SenderNotOwner.selector, propertyID)
        );
        leasy.leaseProperty(propertyID, renters, _depositAmount);
    }

    /**
     * @dev Verifies that when calling `leaseProperty` and that the property owned by the sender it succeeds.
     * @param _owner Owner of the property.
     * @param _renter1 Address of a renter.
     * @param _renter2 Address of another renter.
     * @param _renter3 Address of another renter.
     * @param _depositAmount Amount of the deposit to pay before the property can be rented.
     */
    function test_GivenPropertyExist_AndSenderIsOwner_WhenLeasingProperty_ThenSuccess(
        address _owner,
        address _renter1,
        address _renter2,
        address _renter3,
        uint _depositAmount
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_depositAmount != 0);
        _assumeDistinctRenters(_owner, _renter1, _renter2, _renter3);
        address[] memory renters = _initializeRenters(
            _renter1,
            _renter2,
            _renter3
        );
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);

        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyLeasingInitiated(propertyID);

        bool result = leasy.leaseProperty(propertyID, renters, _depositAmount);

        assertTrue(result);

        Leasy.Property memory property = leasy.getProperties()[0];
        assertEq(property.depositAmount, _depositAmount);
        assertEq(property.renters, renters);
        assertEq(property.renters.length, property.signatureStatuses.length);
    }

    /**
     * @dev Verifies that when calling `signLease` and that the property does not exist then it reverts with a
     *      `PropertyDoesNotExist` error.
     * @param _owner Owner of the property.
     * @param _propertyID ID of the property.
     */
    function test_GivenPropertiesExist_AndPropertyIDNotExist_WhenSigningLease_ThenPropertyDoesNotExistRevert(
        address _owner,
        uint _propertyID
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_propertyID != propertyFixture1.id && _propertyID > 1);

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.expectRevert(
            abi.encodeWithSelector(
                ILeasy.PropertyDoesNotExist.selector,
                _propertyID
            )
        );

        leasy.signLease(_propertyID, ILeasy.SignatureStatus.APPROVED);
    }

    /**
     * @dev Verifies that when calling `leaseProperty` and the leasing process wasn't initiated for the property then
     *      it reverts with `PropertyNotProcessing` error.
     * @param _owner Owner of the property.
     * @param _notRenter Address different than any of the renters addresses.
     */
    function test_GivenPropertyExist_AndLeasingNotInitiated_WhenSigningLease_ThenSenderNotRenterRevert(
        address _owner,
        address _notRenter
    ) public {
        vm.assume(_owner != address(0));
        vm.assume(_notRenter != address(0));
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        vm.stopPrank();

        vm.startPrank(_notRenter);

        vm.expectRevert(
            abi.encodeWithSelector(
                ILeasy.PropertyNotProcessing.selector,
                propertyID
            )
        );

        leasy.signLease(propertyID, ILeasy.SignatureStatus.APPROVED);
    }

    /**
     * @dev Verifies that when calling `leaseProperty` and the leasing process was initiated for the property and
     *      the sender is not a designated renter then it reverts with a `SenderNotRenter` error.
     * @param _owner Owner of the property.
     * @param _renter1 Address of a renter.
     * @param _renter2 Address of another renter.
     * @param _renter3 Address of another renter.
     * @param _notRenter Address different than any of the renters addresses.
     */
    function test_GivenPropertyExist_AndLeasingInitiated_AndSenderNotADesignatedRenter_WhenSigningLease_ThenSenderNotRenterRevert(
        address _owner,
        address _renter1,
        address _renter2,
        address _renter3,
        address _notRenter
    ) public {
        vm.assume(_owner != address(0));
        _assumeDistinctRenters(_owner, _renter1, _renter2, _renter3);
        vm.assume(
            _notRenter != address(0) &&
                _notRenter != _renter1 &&
                _notRenter != _renter2 &&
                _notRenter != _renter3
        );
        address[] memory renters = _initializeRenters(
            _renter1,
            _renter2,
            _renter3
        );
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        leasy.leaseProperty(propertyID, renters, 1000);
        vm.stopPrank();

        vm.startPrank(_notRenter);

        vm.expectRevert(
            abi.encodeWithSelector(ILeasy.SenderNotRenter.selector, propertyID)
        );

        leasy.signLease(propertyID, ILeasy.SignatureStatus.APPROVED);
    }

    /**
     * @dev Verifies that when calling `leaseProperty` and the leasing process was initiated for the property and
     *      the sender is one of the designated renters then the signature status decision is successfully persisted.
     * @param _owner Owner of the property.
     * @param _renter1 Address of a renter.
     * @param _renter2 Address of another renter.
     * @param _renter3 Address of another renter.
     */
    function test_GivenPropertyExist_AndLeasingInitiated_AndSenderADesignatedRenter_WhenSigningLease_ThenSuccess(
        address _owner,
        address _renter1,
        address _renter2,
        address _renter3
    ) public {
        vm.assume(_owner != address(0));
        _assumeDistinctRenters(_owner, _renter1, _renter2, _renter3);
        address[] memory renters = _initializeRenters(
            _renter1,
            _renter2,
            _renter3
        );
        uint propertyID = propertyFixture1.id;

        vm.startPrank(_owner);
        _addProperty(propertyFixture1);
        leasy.leaseProperty(propertyID, renters, 1000);
        vm.stopPrank();

        vm.startPrank(_renter2);

        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyLeaseSignatureSaved(
            propertyID,
            _renter2,
            ILeasy.SignatureStatus.APPROVED
        );

        bool result = leasy.signLease(
            propertyID,
            ILeasy.SignatureStatus.APPROVED
        );

        assertTrue(result);
    }

    /**
     * @dev Helper function that delegates to `leasy#addProperty`.
     * @param _property The property to add.
     */
    function _addProperty(Leasy.Property memory _property) private {
        leasy.addProperty(
            _property.name,
            _property.fullAddress,
            _property.leaseAgreementUrl
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
     * @dev Initializes the test fixtures.
     */
    function _initializeTestFixtures() private {
        propertyFixture1.id = 1;
        propertyFixture1.name = "Tiny House";
        propertyFixture1.fullAddress = "123 Fake Street";
        propertyFixture1.leaseAgreementUrl = "https://bitcoin.org/bitcoin.pdf";
        propertyFixture1.status = ILeasy.PropertyStatus.AVAILABLE;
        propertyFixture1.owner = address(1);

        propertyFixture2.id = 2;
        propertyFixture2.name = "Small House";
        propertyFixture2.fullAddress = "456 Fake Street";
        propertyFixture2.leaseAgreementUrl = "https://etherscan.io";
        propertyFixture2.status = ILeasy.PropertyStatus.AVAILABLE;
        propertyFixture1.owner = address(2);
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
