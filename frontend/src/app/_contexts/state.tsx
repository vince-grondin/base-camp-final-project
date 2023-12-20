import { createContext, useContext, useState } from 'react';
import { Property } from '../Models';
import { useContractRead } from 'wagmi';
import contractData from '../../../../contracts/out/Leasy.sol/Leasy.json';

const PropertiesContext = createContext<Property[]>([]);

type PropertiesContextProviderProps = { children: React.ReactNode };

export function PropertiesContextProvider({ children }: PropertiesContextProviderProps) {
    const [properties, setProperties] = useState<Property[]>([]);

    const { data, isError, isLoading } = useContractRead({
        address: process.env.NEXT_PUBLIC_LEASY_CONTRACT_ADDRESS as `0x${string}`,
        abi: contractData.abi,
        functionName: 'getProperties',
        onSuccess(data) {
            const processedData = (data as Property[]);
            processedData.shift(); // Removes zero-value at index 0
            setProperties(processedData);
        },
    });

    return <PropertiesContext.Provider value={properties}>{children}</PropertiesContext.Provider>;
}

export function usePropertiesContext() {
    return useContext(PropertiesContext);
}
