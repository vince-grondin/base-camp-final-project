export type Property = {
    id: number,
    name: string,
    fullAddress: string,
    owner: `0x${string}`,
    picturesUrls: string,
    status: PropertyStatus,
    depositAmount: number,
    applicants: `0x${string}`[],
    applicantsDates: string[],
    renters: `0x${string}`[],
    rentersDates: string[],
}

export enum PropertyStatus { INACTIVE, AVAILABLE }
