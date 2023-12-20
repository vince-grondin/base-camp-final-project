"use client";
import { SignerStatus } from "@/app/Models";
import { properties } from "@/app/_fixtures/Properties"
import { useAccount } from "wagmi";

export type PropertyDetailsParams = {
    propertyID: number
}

export type PropertyDetailsProps = {
    params: PropertyDetailsParams
}

export default function PropertyDetails({ params: { propertyID } }: PropertyDetailsProps) {
    const property = properties.find(it => it.id == propertyID);
    if (!property) throw new Error(`Property ${propertyID} not found!`);

    const { address: connectedAddress, isConnecting, isDisconnected } = useAccount();

    const { name, owner, address, leaseAgreementUrl, signers, signersStatuses } = property;

    function isPdf(documentUrl: string) {
        return leaseAgreementUrl.endsWith('.pdf');
    }

    return <div>
        <h1 className="text-3xl block mb-5">🏠 {name}</h1>

        <h4>👤 Owned by {owner == connectedAddress ? 'you' : owner}</h4>

        <span>📍 Located at
            &nbsp;<a target="_blank" href={`https://www.google.com/maps/place/${address}`}>{address}</a>
        </span>

        <hr className="mt-5 mb-5" />

        <h2 className="text-2xl mb-2">📃 Lease</h2>
        <h3 className="text-lg">✍️ Signatures</h3>
        {(!signers || signers.length === 0) &&
            <div>
                Lease not sent to any signers.
            </div>
        }
        {signers && signers.length > 0 &&
            <ul>
                {signers.map((address, index) =>
                    <SignerRow {...{ address, status: signersStatuses[index] || null }} />)
                }
            </ul>
        }

        <h3 className="text-lg mt-5">Agreement</h3>
        {isPdf(leaseAgreementUrl) && <iframe title="lease" src={leaseAgreementUrl} width={800} height={800} />}
        {!isPdf(leaseAgreementUrl) && <a target="_blank" href={leaseAgreementUrl}>Open 🔗</a>}
    </div>
}

type SignerRowProps = {
    address: `0x${string}`,
    status: SignerStatus | null
}

function SignerRow({ address, status }: SignerRowProps) {
    function statusIcon() {
        switch (status) {
            case SignerStatus.APPROVED: return "✅";
            case SignerStatus.DECLINED: return "❌";
            default: "↗️"
        }
    }

    return <li>{statusIcon()} {address}</li>
}
