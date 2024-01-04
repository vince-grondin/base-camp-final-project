"use client";
import { Booking, BookingStatus, Property } from "@/app/Models";
import { PropertyStatusBadge } from "@/app/_components/PropertyStatusBadge";
import { useState } from "react";
import { useAccount, useContractRead } from "wagmi";
import contractData from '../../../../../contracts/out/Leasy.sol/Leasy.json';

export type PropertyDetailsParams = {
    propertyID: number
}

export type PropertyDetailsProps = {
    params: PropertyDetailsParams
}

export default function PropertyDetails({ params: { propertyID } }: PropertyDetailsProps) {
    const [property, setProperty] = useState<Property | null>(null);

    const [bookings, setBookings] = useState<Booking[]>([]);
    const pendingBookings = bookings.filter(({ status }) => status === BookingStatus.REQUESTED);
    const acceptedBookings = bookings.filter(({ status }) => status === BookingStatus.ACCEPTED);
    const { address: connectedAddress, isConnecting, isDisconnected } = useAccount();

    useContractRead({
        address: process.env.NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS as `0x${string}`,
        abi: contractData.abi,
        functionName: 'getProperty',
        args: [propertyID],
        onError(error) {
            console.log(error);
            // TODO Render failure message on screen
            if (!property) throw new Error(`Property ${propertyID} not found!`);
        },
        onSuccess(data) {
            console.log(data);
            setProperty(data as Property);
        },
    });

    useContractRead({
        address: process.env.NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS as `0x${string}`,
        abi: contractData.abi,
        functionName: 'getBookings',
        args: [propertyID],
        onError(error) {
            console.log(error);
        },
        onSuccess(data) {
            setBookings(data as Booking[]);
        },
    });

    if (property === null) return <div>Loading...</div>

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

        <hr className="mt-5 mb-5" />

        <h3 className="text-xl">Bookings</h3>
        <h3 className="text-lg">👀 Pending Bookings</h3>
        {pendingBookings.length == 0 && <div><span className="italic">No pending bookings.</span></div>
        }
        {pendingBookings.length > 0 &&
            <ul>
                {pendingBookings.map(({ booker, dates }, index) =>
                    <li>{booker} - {dates.reduce((acc: string, curr: string) => `${acc}, ${curr}`)}</li>
                )}
            </ul>
        }

        <h3 className="text-lg mt-2">✅ Accepted Bookings</h3>
        {acceptedBookings.length == 0 && <div><span className="italic">No accepted bookings.</span></div>}
        {acceptedBookings.length > 0 &&
            <ul>
                {acceptedBookings.map(({ booker, dates }, index) =>
                    <li>{booker} - {dates.reduce((acc: string, curr: string) => `${acc}, ${curr}`)}</li>
                )}
            </ul>
        }
    </div>
}
