export type Booking = {
    id: number,
    booker: `0x${string}`,
    propertyID: number;
    depositAmount: number;
    dates: string[];
    status: BookingStatus;
}

export enum BookingStatus { REQUESTED, ACCEPTED, ENDED }

export type Property = {
    id: number,
    name: string,
    fullAddress: string,
    owner: `0x${string}`,
    picturesUrls: string,
    status: PropertyStatus,
    depositAmount: number
}

export enum PropertyStatus { INACTIVE, AVAILABLE }
