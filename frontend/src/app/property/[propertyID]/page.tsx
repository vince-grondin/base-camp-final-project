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

    const { name, owner, fullAddress, picturesUrls, renters, signatureStatuses, status, depositAmount } = property;

    return <div>
        <div className="mb-5">
            <span className="text-4xl inline-block me-5">🏠 {name}</span>
            <PropertyStatusBadge status={status} />
        </div>

        <img title="lease" src={picturesUrls} width={400} height={400} />

        <div className="mt-5">🔑 Owned by {owner == connectedAddress ? 'you' : owner}</div>

        <div>📍 Located at&nbsp;
            <a className="underline" target="_blank" href={`https://www.google.com/maps/place/${fullAddress}`}>{fullAddress}</a>
        </div>

        <div>💰 Deposit: {depositAmount.toString()}</div>

        <hr className="mt-5 mb-5" />

        <h3 className="text-lg">👤 Renters</h3>
        {(!renters || renters.length === 0) &&
            <div>
                <span className="italic">No renters were assigned to this property.</span>
            </div>
        }
        {renters && renters.length > 0 &&
            <ul>
                {renters.map((address, index) =>
                    <RenterRow {...{ address, status: signatureStatuses[index] ?? null }} />)
                }
            </ul>
        }

    </div>
}

type RenterRowProps = {
    address: `0x${string}`,
    status: SignerStatus | null
}

function RenterRow({ address, status }: RenterRowProps) {
    function statusIcon() {
        switch (status) {
            case SignerStatus.APPROVED: return <span>✅</span>;
            case SignerStatus.DECLINED: return <span>❌</span>;
            case SignerStatus.PENDING: return <span>↗️</span>
        }
    }

    return <li>{statusIcon()} {address}</li>
}
