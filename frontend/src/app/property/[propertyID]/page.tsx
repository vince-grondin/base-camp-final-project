"use client";
import { Property } from "@/app/Models";
import { PropertyStatusBadge } from "@/app/_components/PropertyStatusBadge";
import { useState } from "react";
import { useAccount, useContractRead } from "wagmi";
import contractData from '../../../../../contracts/out/Leasy.sol/Leasy.json';
import BookingsSection from "@/app/_components/Bookings";

export type PropertyDetailsParams = {
    propertyID: number
}

export type PropertyDetailsProps = {
    params: PropertyDetailsParams
}

export default function PropertyDetails({ params: { propertyID } }: PropertyDetailsProps) {
    const [property, setProperty] = useState<Property | null>(null);
    const { address: connectedAddress } = useAccount();
    const [isFetching, setIsFetching] = useState(true);
    const [errorMessage, setErrorMessage] = useState("");

    useContractRead({
        address: process.env.NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS as `0x${string}`,
        abi: contractData.abi,
        functionName: 'getProperty',
        args: [propertyID],
        onError(error) {
            console.log(error);
            setErrorMessage(`Unable to retrieve details for property ${propertyID}!`);
            setIsFetching(false);
        },
        onSuccess(data) {
            setProperty(data as Property);
            setIsFetching(false);
        },
    });

    if (isFetching === null) return <div>Retrieving property details...</div>
    if (errorMessage) return <div className="text-red-600">{errorMessage}</div>
    if (property === null) return

    const {
        name,
        owner,
        fullAddress,
        picturesUrls,
        status,
        depositAmount
    } = property;

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

        <div>💰 Deposit: {depositAmount.toString()} wei</div>

        {property.owner === connectedAddress &&
            <>
                <hr className="mt-5 mb-5" />
                <BookingsSection {...{ propertyID }} />
            </>
        }
    </div>
}
