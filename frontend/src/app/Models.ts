export type Property = {
    id: number,
    name: string,
    fullAddress: string,
    owner: `0x${string}`,
    picturesUrls: string,
    status: PropertyStatus,
    depositAmount: number,
    renters: `0x${string}`[],
    signatureStatuses: SignerStatus[]
}

export enum PropertyStatus { INACTIVE, AVAILABLE, ASSIGNED, RENTING }

export enum SignerStatus { DEFAULT, PENDING, APPROVED, DECLINED }
