"use client";
import { PropertyStatus, SignerStatus } from "@/app/Models";
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

    const {
        name,
        owner,
        fullAddress,
        picturesUrls,
        applicants,
        applicantsDates,
        renters,
        rentersDates,
        status,
        depositAmount
    } = property;

    function shouldShowApplicants() {
        return applicants.length > 0 && renters.length === 0;
    }

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

        {status !== PropertyStatus.INACTIVE &&
            <>
                <div>💰 Deposit: {depositAmount.toString()}</div>

                {connectedAddress === owner && <ApplicantsSection {...{ applicants, applicantsDates }} />}

                {connectedAddress === owner && <RentersSection {...{ renters, rentersDates }} />}
            </>
        }
    </div>
}

type ApplicantsSectionProps = {
    applicants: `0x${string}`[],
    applicantsDates: string[]
}

function ApplicantsSection({ applicants, applicantsDates }: ApplicantsSectionProps) {
    return <div className="mt-5 mb-5">
        <h3 className="text-lg">👋 Applicants</h3>
        {(!applicants || applicants.length === 0) &&
            <div>
                <span className="italic">No new applicants for this property.</span>
            </div>
        }
        {applicants && applicants.length > 0 &&
            <ul>
                {applicants.map((address, index) =>
                    <li>{address} - {applicantsDates[index].replaceAll(',', ', ')}</li>
                )}
            </ul>
        }
    </div>
}

type RentersSectionProps = {
    renters: `0x${string}`[],
    rentersDates: string[]
}

function RentersSection({ renters, rentersDates }: RentersSectionProps) {
    return <>
        <h3 className="text-lg">👤 Renters</h3>
        {(!renters || renters.length === 0) &&
            <div>
                <span className="italic">No renters were assigned to this property.</span>
            </div>
        }
        {renters && renters.length > 0 &&
            <ul>
                {renters.map((address, index) =>
                    <li>{address} - {rentersDates[index].replaceAll(',', ', ')}</li>
                )}
            </ul>
        }
    </>
}
