import { PropertyStatus } from "../Models";

export function PropertyStatusBadge({ status }: { status: PropertyStatus }) {
    switch (status) {
        case PropertyStatus.INACTIVE:
            return <div className="inline-flex items-center px-2 py-1 bg-gray-500 border rounded-md font-semibold">
                <span className="text-white-800 border-gray-300">{PropertyStatus[status]}</span>
            </div>;
        case PropertyStatus.AVAILABLE:
            return <div className="inline-flex items-center px-2 py-1 bg-green-500 border rounded-md font-semibold">
                <span className="text-white-800 border-green-300">{PropertyStatus[status]}</span>
            </div>;
        case PropertyStatus.ASSIGNED:
            return <div className="inline-flex items-center px-2 py-1 bg-blue-500 border rounded-md font-semibold">
                <span className="text-white-800 border-blue-300">{PropertyStatus[status]}</span>
            </div>;
        case PropertyStatus.RENTING:
            return <div className="inline-flex items-center px-2 py-1 bg-orange-500 border rounded-md font-semibold">
                <span className="text-white-800 border-green-300">{PropertyStatus[status]}</span>
            </div>;
    }
}
