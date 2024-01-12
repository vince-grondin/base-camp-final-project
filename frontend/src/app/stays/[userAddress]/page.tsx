"use client";
import { useState } from "react";
import { useAccount, useContractRead } from "wagmi";
import contractData from '../../../../../contracts/out/LeasyStay.sol/LeasyStay.json';
import { Stay } from "@/app/Models";

export type StaysGridParams = {
    userAddress: `0x${string}`
}

export type StaysGridProps = {
    params: StaysGridParams
}

export default function StaysGrid({ params: { userAddress } }: StaysGridProps) {
    const [stays, setStays] = useState<Stay[]>([]);
    const { address: connectedAddress } = useAccount();
    const [isFetching, setIsFetching] = useState(true);
    const [errorMessage, setErrorMessage] = useState("");

    useContractRead({
        address: process.env.NEXT_PUBLIC_LEASY_STAY_CONTRACT_ADDRESS as `0x${string}`,
        abi: contractData.abi,
        functionName: 'getMyStays',
        onError(error) {
            console.log(error);
            setErrorMessage(`Unable to retrieve stays for ${connectedAddress}!`);
            setIsFetching(false);
        },
        onSuccess(data) {
            console.log(data);
            setStays(data as Stay[]);
            setIsFetching(false);
        },
        account: userAddress
    });

    if (isFetching === null) return <div>Retrieving stays...</div>
    if (errorMessage) return <div className="text-red-600">{errorMessage}</div>

    return <div>
        <div className="mb-5">
            <span className="text-4xl me-5">Your Stays Rewards</span>
        </div>

        {stays.length == 0 && <div><span className="italic">No stay rewards. Book and complete a stay a property to get rewards!</span></div>
        }
        {stays.length > 0 &&
            <div className="grid grid-cols-4 gap-4">
                {
                    stays.map(({ id, bookingID, propertyID, dates }) =>
                        <div key={id} className="p-6 bg-white rounded-xl shadow-lg text-zinc-600">
                            ID: {id.toString()}
                            <br />
                            Booking ID: {bookingID.toString()}
                            <br />
                            Property ID: {propertyID.toString()}
                            <br />
                            Dates: #{dates.reduce((acc: string, curr: string) => `${acc}, ${curr}`)}
                        </div>
                    )
                }
            </div>
        }
    </div>
}
