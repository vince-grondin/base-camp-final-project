"use client";
import { Booking, BookingStatus, Property } from "@/app/Models";
import { useState } from "react";
import { useContractRead } from "wagmi";
import contractData from '../../../../contracts/out/Leasy.sol/Leasy.json';

export type BookingsSectionProps = {
    propertyID: number
}

export default function BookingsSection({ propertyID }: BookingsSectionProps) {
    const [bookings, setBookings] = useState<Booking[]>([]);
    const pendingBookings = bookings.filter(({ status }) => status === BookingStatus.REQUESTED);
    const acceptedBookings = bookings.filter(({ status }) => status === BookingStatus.ACCEPTED);

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
        watch: true
    });

    return <div>
        <h3 className="text-xl">Bookings</h3>
        <h3 className="text-lg">👀 Pending Bookings</h3>
        {pendingBookings.length == 0 && <div><span className="italic">No pending bookings.</span></div>
        }
        {pendingBookings.length > 0 &&
            <ul>
                {pendingBookings.map(({ id, booker, dates }, index) =>
                    <li key={index}>Booking #{id.toString()}: {booker} - {dates.reduce((acc: string, curr: string) => `${acc}, ${curr}`)}</li>
                )}
            </ul>
        }

        <h3 className="text-lg mt-2">✅ Accepted Bookings</h3>
        {acceptedBookings.length == 0 && <div><span className="italic">No accepted bookings.</span></div>}
        {acceptedBookings.length > 0 &&
            <ul>
                {acceptedBookings.map(({ id, booker, dates }, index) =>
                    <li key={index}>Booking #{id.toString()}: {booker} - {dates.reduce((acc: string, curr: string) => `${acc}, ${curr}`)}</li>
                )}
            </ul>
        }
    </div>
}
