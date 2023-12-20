import Link from "next/link";
import PropertyCard from "./PropertyCard"
import { usePropertiesContext } from "../_contexts/state";

export default function PropertiesGrid() {
    const properties = usePropertiesContext();

    return <div className="grid grid-cols-4 gap-4">
        {
            properties.map((property) =>
                <Link key={property.id} href={`/property/${property.id}`}><PropertyCard {...{ property }} /></Link>
            )
        }
    </div>
}
