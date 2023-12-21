"use client";
import { SignerStatus } from "@/app/Models";
import { PropertyStatusBadge } from "@/app/_components/PropertyStatusBadge";
import { usePropertiesContext } from "@/app/_contexts/state";
import { useAccount } from "wagmi";

export type PropertyDetailsParams = {
    propertyID: number
}

export type PropertyDetailsProps = {
    params: PropertyDetailsParams
}

export default function PropertyDetails({ params: { propertyID } }: PropertyDetailsProps) {
    const properties = usePropertiesContext();
    const property = properties.find(it => it.id == propertyID);
    if (!property) throw new Error(`Property ${propertyID} not found!`);

    const { address: connectedAddress, isConnecting, isDisconnected } = useAccount();

    const { name, owner, fullAddress, leaseAgreementUrl, renters, signatureStatuses, status } = property;

    function canBeRendered(documentUrl: string) {
        return leaseAgreementUrl.endsWith('.pdf');
    }

    return <div>
        <div className="mb-5">
            <span className="text-3xl mb-10 me-5">🏠 {name}</span>
            <PropertyStatusBadge status={status} />
        </div>
        <h4>👤 Owned by {owner == connectedAddress ? 'you' : owner}</h4>

        <span>📍 Located at&nbsp;
            <a className="underline" target="_blank" href={`https://www.google.com/maps/place/${fullAddress}`}>{fullAddress}</a>
        </span>

        <hr className="mt-5 mb-5" />

        <h2 className="text-2xl mb-2">📃 Lease</h2>
        <h3 className="text-lg">✍️ Signatures</h3>
        {(!renters || renters.length === 0) &&
            <div>
                Lease not sent to any renters.
            </div>
        }
        {renters && renters.length > 0 &&
            <ul>
                {renters.map((address, index) =>
                    <SignerRow {...{ address, status: signatureStatuses[index] ?? null }} />)
                }
            </ul>
        }

        <h3 className="text-lg mt-5">Agreement</h3>
        {canBeRendered(leaseAgreementUrl) && <iframe title="lease" src={leaseAgreementUrl} width={800} height={800} />}
        {!canBeRendered(leaseAgreementUrl) && <a className="underline" target="_blank" href={leaseAgreementUrl}>Open 🔗</a>}
    </div>
}

type SignerRowProps = {
    address: `0x${string}`,
    status: SignerStatus | null
}

function SignerRow({ address, status }: SignerRowProps) {
    function statusIcon() {
        switch (status) {
            case SignerStatus.APPROVED: return <span>✅</span>;
            case SignerStatus.DECLINED: return <span>❌</span>;
            case SignerStatus.PENDING: return <span>↗️</span>
        }
    }

    return <li>{statusIcon()} {address}</li>
}
