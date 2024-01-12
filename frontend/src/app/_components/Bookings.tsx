"use client";
import { Booking, BookingStatus, Property } from "@/app/Models";
import { useState } from "react";
import { useContractRead } from "wagmi";
import contractData from '../../../../contracts/out/Leasy.sol/Leasy.json';
import Link from "next/link";

export type BookingsSectionProps = {
    propertyID: number
}

export default function BookingsSection({ propertyID }: BookingsSectionProps) {
    const [bookings, setBookings] = useState<Booking[]>([]);
    const acceptedBookings = bookings.filter(({ status }) => status === BookingStatus.ACCEPTED);
    const endedBookings = bookings.filter(({ status }) => status === BookingStatus.ENDED);
    const pendingBookings = bookings.filter(({ status }) => status === BookingStatus.REQUESTED);

    useContractRead({
        address: process.env.NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS as `0x${string}`,
        abi: contractData.abi,
        functionName: 'getBookings',
        args: [propertyID],
        onError(error) {
            console.log(error);
        },
        onSuccess(data) {
            console.log(data);
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
                {pendingBookings.map((booking, index) => <BookingRow key={index} {...booking} />)}
            </ul>
        }

        <h3 className="text-lg mt-2">✅ Accepted Bookings</h3>
        {acceptedBookings.length == 0 && <div><span className="italic">No accepted bookings.</span></div>}
        {acceptedBookings.length > 0 &&
            <ul>
                {acceptedBookings.map((booking, index) => <BookingRow key={index} {...booking} />)}
            </ul>
        }

        <h3 className="text-lg mt-2">✅✅ Ended Bookings</h3>
        {endedBookings.length == 0 && <div><span className="italic">No completed bookings.</span></div>}
        {endedBookings.length > 0 &&
            <ul>
                {endedBookings.map((booking, index) => <BookingRow key={index} {...booking} />)}
            </ul>
        }
    </div>
}

function BookingRow({ id, booker, dates }: Booking) {
    return <li>
        Booking #{id.toString()}:&nbsp;
        <Link className="underline" href={`/stays/${booker}`}>{booker}</Link>&nbsp;
        -&nbsp;
        {dates.reduce((acc: string, curr: string) => `${acc}, ${curr}`)}
    </li>
}
