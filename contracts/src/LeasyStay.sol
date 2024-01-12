// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

/**
 * @title Contract maintaining records of stays at properties maintained by the `Leasy` contract.
 * @author Roch
 */
interface ILeasyStay is IERC721 {
    event StaySaved(uint stayID, address booker, uint propertyID);

    struct Stay {
        uint id;
        uint bookingID;
        address booker;
        uint propertyID;
        string[] dates;
    }

    /**
     * @notice Returns the array of stays for the user.
     * @return _myStays The array of stays for the user.
     */
    function getMyStays() external returns (Stay[] memory _myStays);

    /**
     * @notice Mints a record as a proof a user completed their stay at the property identified by the supplied
     *         `_propertyID`.
     * @param _bookingID The identifier of the booking completed in the `Leasy` contract.
     * @param _booker The address of the user who completed the booking.
     * @param _propertyID The identifier of the property where the user completed their stay.
     * @param _dates The dates the user stayed at the property.
     */
    function saveStay(
        uint _bookingID,
        address _booker,
        uint _propertyID,
        string[] memory _dates
    ) external returns (bool);
}

contract LeasyStay is ILeasyStay, ERC721 {
    Stay[] internal stays;
    mapping(address owner => uint[] userStayIndexes) internal userStays;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        // Avoid 0 index
        stays.push();
    }

    /// @inheritdoc ILeasyStay
    function saveStay(
        uint _bookingID,
        address _booker,
        uint _propertyID,
        string[] memory _dates
    ) external override returns (bool) {
        // TODO Revert if any of the dates are in the future?

        uint stayID = stays.length;
        uint stayIndex = stays.length;

        _mint(_booker, stayID);

        stays.push(
            Stay({
                id: stayID,
                bookingID: _bookingID,
                booker: _booker,
                propertyID: _propertyID,
                dates: _dates
            })
        );

        userStays[_booker].push(stayIndex);

        emit StaySaved(stayID, _booker, _propertyID);

        return true;
    }

    /// @inheritdoc ILeasyStay
    function getMyStays() external view override returns (Stay[] memory _myStays) {
        _myStays = new Stay[](userStays[_msgSender()].length);

        for (uint i = 0; i < userStays[_msgSender()].length; i++) {
            _myStays[i] = stays[userStays[_msgSender()][i]];
        }
    }
}
