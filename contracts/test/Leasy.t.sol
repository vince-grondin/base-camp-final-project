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

        leasy.addProperty(
            propertyFixture1.name,
            propertyFixture1.fullAddress,
            propertyFixture1.leaseAgreementUrl
        );
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result = leasy.getProperties();

        assertEq(result.length, 2);
        _assertEqProperty(result[0], defaultProperty);

        Leasy.Property memory expectedProperty1 = propertyFixture1;
        expectedProperty1.owner = _owner;

        _assertEqProperty(result[1], expectedProperty1);
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
        leasy.addProperty(
            propertyFixture1.name,
            propertyFixture1.fullAddress,
            propertyFixture1.leaseAgreementUrl
        );
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result1 = leasy.getProperties();
        vm.stopPrank();

        assertEq(result1.length, 2);
        _assertEqProperty(result1[0], defaultProperty);
        _assertEqProperty(result1[1], expectedProperty1);

        vm.startPrank(_owner2);
        vm.expectEmit(true, true, true, true, address(leasy));
        emit PropertyAdded(2);
        leasy.addProperty(
            propertyFixture2.name,
            propertyFixture2.fullAddress,
            propertyFixture2.leaseAgreementUrl
        );
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result2 = leasy.getProperties();

        assertEq(result2.length, 3);
        _assertEqProperty(result2[0], defaultProperty);
        _assertEqProperty(result2[1], expectedProperty1);
        _assertEqProperty(result2[2], expectedProperty2);
    }

    /**
     * @dev Verifies that calling `getProperties` before adding any properties returns an array with a single element
     *      with zero values.
     */
    function test_GivenNoPropertiesAdded_WhenGettingProperties_ThenArrayWithOneItemWithZeroValuesReturned()
        public
    {
        Leasy.Property[] memory result = leasy.getProperties();

        assertEq(result.length, 1);
        _assertEqProperty(result[0], defaultProperty);
    }

    /**
     * @dev Verifies that calling `getProperties` after adding a property return an array with two elements: the
     *      zero values element at index 0 and the property added by `_owner` at index 1.
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
        leasy.addProperty(
            propertyFixture1.name,
            propertyFixture1.fullAddress,
            propertyFixture1.leaseAgreementUrl
        );
        vm.stopPrank();

        vm.startPrank(_retriever);
        Leasy.Property[] memory result = leasy.getProperties();

        assertEq(result.length, 2);
        _assertEqProperty(result[0], defaultProperty);

        Leasy.Property memory expectedProperty1;
        expectedProperty1.id = 1;
        expectedProperty1.name = propertyFixture1.name;
        expectedProperty1.fullAddress = propertyFixture1.fullAddress;
        expectedProperty1.leaseAgreementUrl = propertyFixture1
            .leaseAgreementUrl;
        expectedProperty1.owner = _owner;

        _assertEqProperty(result[1], expectedProperty1);
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

    /**
     * @dev Initializes the test fixtures.
     */
    function _initializeTestFixtures() private {
        propertyFixture1.id = 1;
        propertyFixture1.name = "Tiny House";
        propertyFixture1.fullAddress = "123 Fake Street";
        propertyFixture1.leaseAgreementUrl = "https://bitcoin.org/bitcoin.pdf";
        propertyFixture1.owner = address(1);

        propertyFixture2.id = 2;
        propertyFixture2.name = "Small House";
        propertyFixture2.fullAddress = "456 Fake Street";
        propertyFixture2.leaseAgreementUrl = "https://etherscan.io";
        propertyFixture1.owner = address(2);
    }
}
