import Link from "next/link";
import PropertyCard from "./PropertyCard"
import { properties } from "../_fixtures/Properties";

export default function PropertiesGrid() {
    return <div className="grid grid-cols-4 gap-4">
        {
            properties.map((property) =>
                <Link href={`/property/${property.id}`}><PropertyCard key={property.id} {...{ property }} /></Link>
            )
        }
    </div>
}
