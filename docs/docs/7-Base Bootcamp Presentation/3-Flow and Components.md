# Components and Flow

## Flow
<details>
```mermaid
---
title: From owner adding a property to users request bookings to owner accepting bookings
---
flowchart
    A[Add property] --> B[Activate property]
    B --> C[Request Booking]
    C --> D[Accept Booking]
    D --> E[Complete Booking]
```
</details>

## Leasy Contract Components

<details>
```mermaid
classDiagram
    class IERC721
    <<interface>> IERC721

    class ILeasy {
        +addProperty(string memory _name, string memory _fullAddress, string memory _picturesUrls) external returns (uint propertyID)
        +activateProperty(uint _propertyID, uint _depositAmount) external returns (bool)
        +requestBooking(uint _propertyID, string[] memory _dates) external payable returns (bool)
        +acceptBooking(uint _bookingID) external returns (bool)
        +getBookings(uint _propertyID) external returns (Booking[] memory propertyBookings)
        +getProperty(uint _propertyID) external view returns (Property memory)
        +getProperties() external returns (Property[] memory)
    }
    <<interface>> ILeasy

    class ERC721 {
        +int name
        +int symbol
    }

    class Leasy {
        -Booking[] bookings
        -Property[] properties
    }

    class Booking {
        +uint id
        +address booker
        +uint propertyID
        +uint depositAmount
        +string[] dates
        +BookingStatus status
    }

    class Property {
        +uint id
        +string name
        +string fullAddress
        +address owner
        +string picturesUrls
        +PropertyStatus status
        +uint depositAmount
    }

    IERC721 <|-- ILeasy : inherits
    ILeasy <|-- Leasy : implements
    ERC721 <|-- Leasy : inherits
    Leasy --o Booking : uses (one-to-many)
    Leasy --o Property : uses (one-to-many)

```
</details>
