import { Property } from "../Models"

export type PropertyCardProps = {
    property: Property
}

export default function PropertyCard({ property: { id, name, address } }: PropertyCardProps) {
    return <div className="p-6 bg-white rounded-xl shadow-lg flex items-center space-x-4">
        <div className="">
            🏠
        </div>
        <div>
            <div className="text-xl font-medium text-black">{name}</div>
            <p className="text-slate-500">{address}</p>
        </div>
    </div>
}
