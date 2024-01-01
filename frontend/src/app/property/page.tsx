"use client";
import { properties } from "@/app/_fixtures/Properties"
import clsx from "clsx";
import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";
import { useAccount, useContractWrite, usePrepareContractWrite } from "wagmi";
import contractData from "../../../../contracts/out/Leasy.sol/Leasy.json";

export default function PropertyForm() {
    const { address: connectedAddress, isConnecting, isDisconnected } = useAccount();
    if (!connectedAddress)
        return <div>Please connect your wallet to add a new property</div>

    const router = useRouter();
    const [name, setName] = useState("");
    const [address, setAddress] = useState("");
    const [picturesUrls, setPicturesUrls] = useState("");
    const [isSaving, setIsSaving] = useState(false);

    const { config: addPropertyConfig, error: addPropertyError } = usePrepareContractWrite({
        address: process.env.NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS! as `0x${string}`,
        abi: contractData.abi,
        functionName: 'addProperty',
        args: [name, address, picturesUrls],
        account: connectedAddress,
        onSettled(data, error) {
            setIsSaving(false);

            if (error) return;
        }
    });
    const { write: addProperty } = useContractWrite(addPropertyConfig);

    async function handleSubmit(event: FormEvent<HTMLFormElement>) {
        event.preventDefault();

        setIsSaving(true);

        addProperty?.();

        // const newPropertyID = await new Promise((resolve) => setTimeout(() => {
        //     const newID = properties.length + 1;
        //     properties.push({
        //         id: newID,
        //         name: name.trim(),
        //         address: address.trim(),
        //         owner: connectedAddress!,
        //         picturesUrls: picturesUrls.trim(),
        //         signers: [],
        //         signersStatuses: []
        //     });
        //     resolve(newID);
        // }, 2000));

        // router.push(`/property/${newPropertyID}`);
    }

    function isValid() {
        return name.trim() !== '' && address.trim() !== '' && picturesUrls !== '';
    }

    return <div>
        <form onSubmit={handleSubmit}>
            <div className="flex flex-col space-y-2 w-fit">
                <div className="flex flex-row">
                    <label htmlFor="name" className="basis-4/12">Name:</label>
                    <input
                        autoComplete="off"
                        className="dark:text-black"
                        type="text"
                        id="name"
                        name="name"
                        size={54}
                        onChange={(event) => setName(event.target.value)}
                        value={name} />
                </div>
                <div className="flex flex-row">
                    <label htmlFor="address" className="basis-4/12">Address:</label>
                    <input
                        autoComplete="off"
                        className="dark:text-black"
                        type="text"
                        id="address"
                        name="address"
                        size={54}
                        onChange={(event) => setAddress(event.target.value)}
                        value={address} />
                </div>
                <div className="flex flex-row">
                    <label htmlFor="picturesUrls" className="basis-4/12">Pictures URLs:</label>
                    <input
                        autoComplete="off"
                        className="dark:text-black"
                        type="text"
                        id="picturesUrls"
                        name="picturesUrls"
                        size={54}
                        onChange={(event) => setPicturesUrls(event.target.value)}
                        value={picturesUrls} />
                </div>
                <div className="flex flex-row justify-end">
                    <button
                        disabled={!isValid() || isSaving}
                        className={
                            clsx({
                                "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded w-40": isValid(),
                                "bg-gray-200 hover:bg-gray-200 text-black font-bold py-2 px-4 rounded w-40": !isValid() || isSaving
                            })
                        }>
                        {isSaving &&
                            <span>Saving <div
                                className="inline-block h-4 w-4 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
                                role="status">
                            </div></span>
                        }
                        {!isSaving && <span>Save</span>}
                    </button>
                </div>
            </div>
        </form>
    </div>
}
