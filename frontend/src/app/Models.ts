export type Property = {
    id: number,
    name: string,
    fullAddress: string,
    owner: `0x${string}`,
    leaseAgreementUrl: string,
    status: PropertyStatus,
    depositAmount: number,
    renters: `0x${string}`[],
    signatureStatuses: SignerStatus[]
}

export enum PropertyStatus {
    AVAILABLE, PROCESSING, RENTING
}

export enum SignerStatus {
    PENDING, APPROVED, DECLINED
}
