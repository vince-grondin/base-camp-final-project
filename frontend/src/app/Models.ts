export type Property = {
    id: number,
    name: string,
    address: string,
    owner: `0x${string}`,
    leaseAgreementUrl: string,
    signers: `0x${string}`[],
    signersStatuses: SignerStatus[]
}

export enum SignerStatus {
    APPROVED, DECLINED
}
