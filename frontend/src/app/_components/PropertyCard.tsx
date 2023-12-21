import { Property } from "../Models"
import { PropertyStatusBadge } from "./PropertyStatusBadge"

export type PropertyCardProps = {
    property: Property
}

export default function PropertyCard({ property: { id, name, fullAddress, status } }: PropertyCardProps) {
    return <div className="p-6 bg-white rounded-xl shadow-lg">
        <div className="mb-2">
            <span className="text-xl font-medium text-black me-2">🏠 {name}</span>
            <p className="text-slate-500">{fullAddress}</p>
        </div>
        <div>
            <PropertyStatusBadge status={status} />
        </div>
    </div>
}
